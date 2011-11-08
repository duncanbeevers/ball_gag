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
  end
end

