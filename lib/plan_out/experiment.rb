require 'logger'
require 'json'
require_relative 'assignment'
require_relative 'op_random'

module PlanOut
  class Experiment
    attr_accessor :name, :salt, :auto_exposure_log, :in_experiment

    def initialize(**inputs)
      @inputs = inputs
      @exposure_logged = false
      @_salt = nil

      @in_experiment = true
      @name = self.class.name
      @auto_exposure_log = true

      setup  # sets name, salt, etc.

      @assignment = Assignment.new(salt)
      @assigned = false
    end

    def _assign
      configure_logger
      assign(@assignment, **@inputs)
      @in_experiment = @assignment.get(:in_experiment, @in_experiment)
      @assigned = true
    end

    def setup
      # to be implemented by subclass
      nil
    end

    def salt
      @_salt || @name
    end

    def configure_logger
      nil
    end

    def requires_assignment
      _assign if !@assigned
    end

    def is_logged?
      @logged
    end

    def requires_exposure_logging
      log_exposure if @auto_exposure_log && @in_experiment && !@exposure_logged
    end

    def get_params
      requires_assignment
      requires_exposure_logging
      @assignment.get_params
    end

    def get(name, default = nil)
      requires_assignment
      requires_exposure_logging
      @assignment.get(name, default)
    end

    def assign(params, *inputs)
      # up to child class to implement
      nil
    end

    def log_event(event_type, extras = nil)
      if extras.nil?
        extra_payload = {event: event_type}
      else
        extra_payload = {
          event: event_type,
          extra_data: extras.clone
        }
      end

      log(as_blob(extra_payload))
    end

    def log(data)
      nil
    end

    def log_exposure(extras = nil)
      @exposure_logged = true
      log_event(:exposure, extras)
    end

    def as_blob(extras = {})
      d = {
        name: @name,
        time: Time.now.to_i,
        salt: salt,
        inputs: @inputs,
        params: @assignment.data
      }

      d.merge!(extras)
    end
  end

  class DefaultExperiment < Experiment
    def assign(params, *inputs)
      params.merge!(get_default_params)
    end

    def get_default_params
      {}
    end
  end

  class SimpleExperiment < Experiment
    def configure_logger
      @logger = Logger.new(STDOUT)
      #@loger.level = Logger::WARN
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "logged data: #{msg}\n"
      end
    end

    def log(data)
      @logger.info(JSON.dump(data))
    end
  end
end
