module BowlingBall
  def self.included base
    base.send(:include, BallGag)
  end
end

