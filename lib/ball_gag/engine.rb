module BallGag
  module Engine
    module ClassMethods
      def engine
        @engine
      end

      def engine= new_engine
        @engine = new_engine
      end
    end
  end

  extend Engine::ClassMethods
end

