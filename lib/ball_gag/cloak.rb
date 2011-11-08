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
    end
  end

  extend Cloak
end

