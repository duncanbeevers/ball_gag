module BallGag
  def self.included base
    @gagged_inclusions ||= {}
    if !@gagged_inclusions[base]
      @gagged_inclusions[base] = true
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def gagged_attributes
      clear_gagged_attributes unless @gagged_attributes
      @gagged_attributes.keys
    end

    def gag *arguments, &block
      define_and_mixin_gagged_attributes_methods

      callable = arguments.pop if arguments.last.respond_to? :call
      options = arguments.pop if arguments.last.kind_of? Hash

      to_call = callable || block || BallGag.engine ||
        lambda { |*| raise NoEngineConfiguredError }

      define_gagged_interpellations(arguments, to_call, options)

      arguments.each do |attribute|
        @gagged_attributes[attribute] = to_call
        define_not_gagged_interpellation attribute
      end
    end

    def clear_gagged_attributes
      undefine_gagged_attributes_methods
    end

    private
    def define_and_mixin_gagged_attributes_methods
      return if @gagged_attributes_methods

      undefine_gagged_attributes_methods
    end

    def define_gagged_interpellations attributes, callable, options = nil
      unsanitized_values = lambda { |instance|
        attributes.inject({}) do |a, attribute|
          a[attribute] = instance.send(attribute)
          a
        end
      }

      fn = options ?
        -> { callable.call(unsanitized_values.call(self), self, options) } :
        -> { callable.call(unsanitized_values.call(self), self) }

      attributes.each do |attribute|
        @gagged_attributes_methods.send(:define_method,
        gagged_attribute_interpellation_name(attribute), &fn)
      end
    end

    def define_not_gagged_interpellation attribute
      gagged_method_name = gagged_attribute_interpellation_name(attribute)
      @gagged_attributes_methods.send(:define_method,
        gagged_attribute_negative_interpellation_name(attribute)) do
          !method(gagged_method_name).call
        end
    end

    def gagged_attribute_interpellation_name attribute
      "#{attribute}_gagged?"
    end

    def gagged_attribute_negative_interpellation_name attribute
      "#{attribute}_not_gagged?"
    end

    def undefine_gagged_attributes_methods
      @gagged_attributes.keys.each do |attribute|

        @gagged_attributes_methods.send(:remove_method,
          gagged_attribute_interpellation_name(attribute))

        @gagged_attributes_methods.send(:remove_method,
          gagged_attribute_negative_interpellation_name(attribute))

      end if @gagged_attributes

      @gagged_attributes_methods = Module.new
      include @gagged_attributes_methods
      @gagged_attributes = {}
    end
  end
end

