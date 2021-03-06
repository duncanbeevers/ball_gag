module BowlingBall
  class << self
    def included base
      base.send(:include, BallGag)
    end

    def engine
      BallGag.engine
    end

    def engine= engine
      BallGag.engine = engine
    end

    def verb
      BallGag.verb
    end

    def verb= verb
      BallGag.verb= verb
    end

    def preterite
      BallGag.preterite
    end

    def preterite= preterite
      BallGag.preterite = preterite
    end

    def negative_preterite= preterite
      BallGag.negative_preterite = preterite
    end

    def only_validate_on_attribute_changed
      BallGag.only_validate_on_attribute_changed
    end

    def only_validate_on_attribute_changed= bool
      BallGag.only_validate_on_attribute_changed = bool
    end

    def enabled?
      BallGag.enabled?
    end

    def enable! &block
      if block
        BallGag.enable! &block
      else
        BallGag.enable!
      end
    end

    def disable! &block
      if block
        BallGag.disable! &block
      else
        BallGag.disable!
      end
    end
  end
end

