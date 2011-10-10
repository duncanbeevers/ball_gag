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
      @gagged_attributes || clear_gagged_attributes
      @gagged_attributes.keys
    end

    def gag attribute
      @gagged_attributes[attribute] = true
    end

    def clear_gagged_attributes
      @gagged_attributes = {}
    end
  end
end

