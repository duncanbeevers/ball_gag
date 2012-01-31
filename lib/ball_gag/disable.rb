module BallGag
  module Disable
    module ClassMethods
      def enable!
        @enabled = true
      end

      def disable!
        @enabled = false
      end

      def enabled?
        return @enabled if @enabled == false
        @enabled || true
      end
    end
  end

  extend Disable::ClassMethods
end

