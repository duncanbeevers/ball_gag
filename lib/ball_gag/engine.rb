module BallGag
  module Engine
    module ClassMethods
      attr_accessor(
        :engine,
        :only_validate_on_attribute_changed
      )

    end
  end

  extend Engine::ClassMethods
end

