module BallGag
  module Disable
    module ClassMethods
      def enable!
        old_enabled = @enabled
        @enabled = true
        if block_given?
          begin
            yield
          ensure
            @enabled = old_enabled
          end
        end
      end

      def disable!
        old_enabled = @enabled
        @enabled = false
        if block_given?
          begin
            yield
          ensure
            @enabled = old_enabled
          end
        end
      end

      def enabled?
        return @enabled if @enabled == false
        @enabled || true
      end
    end
  end

  extend Disable::ClassMethods
end

