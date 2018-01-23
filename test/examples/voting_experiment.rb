require_relative '../../lib/plan_out/experiment'

module PlanOut
  class VotingExperiment < SimpleExperiment
    def setup; end

    def assign(params, **inputs)
      userid = inputs[:userid]
      params[:button_color] = UniformChoice.new({
        choices: ['ff0000', '00ff00'],
        unit: userid
      })

      params[:button_text] = UniformChoice.new({
        choices: ["I'm voting", "I'm a voter"],
        unit: userid,
        salt:'x'
      })
    end
  end
end
