require_relative '../../lib/plan_out/namespace'
require_relative '../../lib/plan_out/experiment'

module PlanOut

  class V1 < SimpleExperiment
    def setup
      @auto_exposure_log = false
    end

    def assign(params, **inputs)
      userid = inputs[:userid]

      params[:banner_text] = UniformChoice.new({
        :choices => ['Banner Text 1', 'Banner Text 2'],
        :unit => userid
      })
    end
  end

  class BannerDefault < DefaultExperiment
    def get_default_params
      {
        :banner_text => 'Banner Text 0'
      }
    end
  end

  class BannerNamespace < SimpleNamespace

    def setup
      @num_segments = 10
      @primary_unit = 'userid'

      @default_experiment_class = BannerDefault
    end

    def setup_experiments
      add_experiment('V1 experiment, small audience', V1, 5)
      # remove_experiment('V1 experiment, small audience')
      # error testing
      # add_experiment('V1 experiment, small audience', V1, 10)
      # add_experiment('V2 experiment, small audience', V1, 5)
    end
  end

  if __FILE__ == $0
    (140000..149999).each do |i| 
      my_ns = BannerNamespace.new(userid:i)
      puts "Banner text: #{my_ns.get('banner_text')}"
      # puts "User #{i} will get banner text: #{my_ns.get('banner_text')}"
      # my_ns.segment_allocations.each { |i, v| puts "#{v} is assigned to #{i}" }
      # break
      # toggling the above disables or re-enables auto-logging
      #my_ns.auto_exposure_log = false
      # puts "\ngetting namespace assignment for user #{i} note: first time triggers a log event"
      # puts "button color is #{my_exp.get(:button_color)} and button text is #{my_exp.get(:button_text)}"
    end
  end
end