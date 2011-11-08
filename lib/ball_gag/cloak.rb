module BallGag
  module Cloak
    def verb
      @verb || 'gag'
    end

    def verb= verb
      old_verb = @verb
      @verb = verb

      BallGag::ClassMethods.instance_eval do
        if verb
          define_method verb do |*args|
            gag *args
          end
        elsif old_verb
          remove_method old_verb
        end
      end
    end

    def preterite
      @preterite || 'gagged'
    end

    def preterite= preterite
      set_preterite preterite
      @preterite_negative = false
    end

    def negative_preterite= preterite
      set_preterite preterite
      @preterite_negative = true
    end

    def preterite_negative?
      @preterite_negative
    end

    private
    def set_preterite preterite
      undefine_old_preterite_validators @preterite
      define_preterite_validators preterite
      
      @preterite = preterite
    end

    def define_preterite_validators preterite
      return unless preterite

      Kernel.const_set(validator_name(preterite), Class.new(GaggedValidator))
      Kernel.const_set(not_validator_name(preterite), Class.new(NotGaggedValidator))
    end

    def undefine_old_preterite_validators preterite
      return unless preterite

      Kernel.send(:remove_const, validator_name(preterite))
      Kernel.send(:remove_const, not_validator_name(preterite))
    end

    def validator_name preterite
      "#{preterite.to_s.capitalize}Validator"
    end

    def not_validator_name preterite
      "Not#{validator_name(preterite)}"
    end

  end

  extend Cloak
end

