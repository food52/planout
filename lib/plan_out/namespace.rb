require_relative 'assignment'

module PlanOut
  class Namespace
    attr_accessor :primary_unit, :default_experiment_class
    attr_reader :name, :num_segments, :current_experiments, :segment_allocations, :available_segments

    def initialize(**inputs)
      @inputs = inputs

      # hash mapping segments to experiment names
      @segment_allocations = {}

      # hash mapping experiment names to experiment objects
      @current_experiments = {}

      @_experiment = nil
      @_default_experiment = nil
      @default_experiment_class = DefaultExperiment
      @_in_experiment = false

      # namespace specific settings
      @name = self.class.name
      @primary_unit = nil
      @num_segments = nil

      setup

      @available_segments = (0...@num_segments).to_a

      # add/remove experiments to namespace
      setup_experiments
    end

    def setup
      # to be implemented by subclass
      # @name = 'sample namespace'
      # @primary_unit = 'userid'
      # @num_segments = 10000
      nil
    end

    def setup_experiments
      # to be implemented by subclass
      # add_experiment('V1 experiment, small audience', V1ExperimentClass, 10)
      nil
    end

    def requires_experiment
      _assign_experiment unless @_experiment
    end

    def requires_default_experiment
      _assign_default_experiment unless @_default_experiment
    end

    def add_experiment(name, exp_object, segments)
      num_avail = @available_segments.length
      
      if num_avail < segments
        puts "error: #{segments} segments requested, only #{num_avail} available."
        return false
      end

      if @current_experiments.key? name.to_sym
        puts "error: there is already an experiment called #{name}"
        return false
      end

      a = Assignment.new(@name)
      a[:sampled_segments] = Sample.new({
        :choices => @available_segments,
        :draws => segments,
        :unit => name
      })

      a[:sampled_segments].each do |segment|
        @segment_allocations[segment] = name
        @available_segments.delete(segment)
      end

      @current_experiments[name.to_sym] = exp_object
    end

    def remove_experiment(name)
      if !@current_experiments.key? name.to_sym
        puts "error: there is no experiment called #{name}"
        return false
      end

      # deallocate segments attached to this experiment
      segments_to_free = @segment_allocations.select {|k,v| v === name}.keys
      segments_to_free.each do |segment|
        @segment_allocations.delete(segment)
        @available_segments.push(segment)
      end

      @current_experiments.delete(name.to_sym)

      true
    end

    def get_segment
      # get the unit
      unit = (@primary_unit.is_a? Array) ?
        @primary_unit.map { |piece| @inputs[piece.to_sym] } :
        @inputs[@primary_unit.to_sym]

      # randomly assign primary unit to a segment
      a = Assignment.new(@name)
      a[:segment] = RandomInteger.new({
        :min => 0,
        :max => @num_segments - 1,
        :unit => unit
      })

      a[:segment]
    end

    def _assign_experiment
      segment = get_segment 

      if @segment_allocations.key? segment
        experiment_name = @segment_allocations[segment]
        experiment = @current_experiments[experiment_name.to_sym].new(@inputs)
        experiment.name = "#{@name}-#{experiment_name}"
        experiment.salt = "#{@name}.#{experiment_name}"

        @_experiment = experiment
        @_in_experiment = experiment.in_experiment
      end

      if !@_in_experiment
        _assign_default_experiment
      end
    end

    def _assign_default_experiment
      @_default_experiment = @default_experiment_class.new(@inputs)
    end

    def default_get(name, default = nil)
      requires_default_experiment

      @_default_experiment.get(name, default)
    end

    def in_experiment
      requires_experiment

      @_in_experiment
    end

    def set_auto_exposure_logging(value)
      requires_experiment

      @_experiment.auto_exposure_log = value if @_experiment
    end

    def get(name, default = nil)
      requires_experiment

      if @_experiment
        @_experiment.get(name, default_get(name, default))
      else
        default_get(name, default)
      end
    end
  end

  class SimpleNamespace < Namespace
    def log_exposure(extras = nil)
      requires_experiment

      @_experiment.log_exposure(extras) if @_experiment
    end

    def log_event(event_type, extras = nil)
      @_experiment.log_event(event_type, extras) if @_experiment
    end
  end
end