require_relative '../../lib/plan_out/namespace'
require_relative '../../lib/plan_out/experiment'

module PlanOut

  # Basic experiments to live in namespace

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

  class V2 < SimpleExperiment
    def setup
      @auto_exposure_log = false
    end

    def assign(params, **inputs)
      userid = inputs[:userid]

      params[:banner_text] = UniformChoice.new({
        :choices => ['Banner Text 3', 'Banner Text 4'],
        :unit => userid
      })
    end
  end

  # Defaults

  class BannerDefault < DefaultExperiment
    def get_default_params
      {
        :banner_text => 'Banner Text 0',
        :banner_color => '#ff0000'
      }
    end
  end

  # Example namespaces

  class BannerNamespaceBase < SimpleNamespace
    def setup
      @num_segments = 100
      @primary_unit = 'userid'

      @default_experiment_class = BannerDefault
    end
  end
end