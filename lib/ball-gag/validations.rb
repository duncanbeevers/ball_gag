module BallGag
  module Validations
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def validates_gag *args, &block
        gag(*args, &block).each do |attribute|
          validate attribute do
            errors.add(attribute) if self.method("#{attribute}_gagged?").call
          end
        end
      end
    end
  end
end

