require 'ball-gag/version'

module BallGag
  def self.included base
    @inclusions ||= {}
    if !@inclusions[base]
      @inclusions[base] = true
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def gagged_attributes
      []
    end
  end
end

