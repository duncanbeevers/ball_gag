module BallGag
  module Validations
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def validates_gag *args, &block
        gag *args, &block
      end
    end
  end
end

