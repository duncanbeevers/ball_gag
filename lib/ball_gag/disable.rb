module BallGag
  module Disable
    module ClassMethods
      def enable!
      end

      def disable!
      end
    end
  end

  extend Disable::ClassMethods
end

