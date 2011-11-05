module BallGag
  module Validations
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def validates_gag *args, &block
        messages_map = nil
        if args.first.kind_of?(Hash)
          messages_map = args.shift
          args = messages_map.keys + args
        end

        gag(*args, &block).each do |attribute|
          validate attribute do
            if self.method("#{attribute}_gagged?").call
              messages_map ?
                errors.add(attribute, messages_map[attribute]) :
                errors.add(attribute)
            end
          end
        end
      end
    end
  end
end

