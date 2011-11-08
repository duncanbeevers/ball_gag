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
      @preterite = preterite
      @preterite_negative = false
    end

    def negative_preterite= preterite
      @preterite = preterite
      @preterite_negative = true
    end

    def preterite_negative?
      @preterite_negative
    end
  end

  extend Cloak
end

