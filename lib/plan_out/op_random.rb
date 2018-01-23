require_relative 'operator'

module PlanOut
  class OpRandom < OpSimple
    LONG_SCALE = Float(0xFFFFFFFFFFFFFFF)

    def get_unit(appended_unit = nil)
      unit = @parameters[:unit]
      unit = [unit] if !unit.is_a? Array

      # if we have an appended unit, make sure it's an array
      # and add it
      if !appended_unit.nil?
        appended_unit = [appended_unit] if !appended_unit.is_a? Array
        unit += appended_unit
      end

      unit
    end

    def get_hash(appended_unit = nil)
      salt_pieces = Array.new
      if @parameters[:full_salt]
        salt_pieces.push(@parameters[:full_salt])
      else
        salt_pieces.push(@mapper.experiment_salt)
        salt_pieces.push(@parameters[:salt])
      end

      # append the unit
      salt_pieces += get_unit(appended_unit)

      # join on a seperator
      salt = salt_pieces.join(@mapper.salt_sep)

      last_hex = (Digest::SHA1.hexdigest(salt))[0..14]
      last_hex.to_i(16)
    end

    def get_uniform(min_val = 0.0, max_val = 1.0, appended_unit = nil)
      zero_to_one = self.get_hash(appended_unit)/LONG_SCALE
      min_val + (max_val-min_val) * zero_to_one
    end
  end

  class RandomFloat < OpRandom
    def simple_execute
      min_val = @parameters.fetch(:min, 0)
      max_val = @parameters.fetch(:max, 1)
      get_uniform(min_val, max_val)
    end
  end

  class RandomInteger < OpRandom
    def simple_execute
      min_val = @parameters.fetch(:min, 0)
      max_val = @parameters.fetch(:max, 1)
      min_val + get_hash() % (max_val - min_val + 1)
    end
  end

  class BernoulliTrial < OpRandom
    def simple_execute
      p = @parameters[:p]
      rand_val = get_uniform(0.0, 1.0)
      (rand_val <= p) ? 1 : 0
    end
  end

  class WeightedChoice < OpRandom
    def simple_execute
      choices = @parameters[:choices]
      weights = @parameters[:weights]

      return [] if choices.length() == 0

      cum_weights = Array.new(weights.length)
      cum_sum = 0.0

      weights.each_with_index do |weight, index|
        cum_sum += weight
        cum_weights[index] = cum_sum
      end

      stop_value = get_uniform(0.0, cum_sum)

      i = 0
      cum_weights.each_with_index do |cum_weight, index|
        return choices[index] if stop_value <= cum_weight
      end
    end
  end

  class UniformChoice < OpRandom
    def simple_execute
      choices = @parameters[:choices]
      return [] if choices.length() == 0
      rand_index = get_hash() % choices.length()
      choices[rand_index]
    end
  end

  class BaseSample < OpRandom
    def copy_choices
      @args[:choices].clone
    end

    def get_num_draws(choices)
      num_draws = choices.length
      if @args[:draws]
        num_draws = @args[:draws].to_i

        if num_draws > choices.length
          raise "#{self.class.name}: cannot make #{num_draws} draws when only #{choices.length} choices are available"
        end
      end
      num_draws
    end
  end

  class Sample < BaseSample
    def simple_execute
      choices = copy_choices
      num_draws = get_num_draws(choices)

      (choices.length - 1).downto(0) do |i|
        j = get_hash(i) % (i + 1)
        choices[i], choices[j] = choices[j], choices[i]
      end

      choices[0..(num_draws - 1)]
    end
  end
end
