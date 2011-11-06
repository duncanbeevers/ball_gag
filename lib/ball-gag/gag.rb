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

      define_not_gagged_interpellations(arguments, to_call, options)

      arguments.each do |attribute|
        @gagged_attributes[attribute] = to_call
        define_gagged_interpellation attribute
      end

      arguments
    end

    def clear_gagged_attributes
      undefine_gagged_attributes_methods
    end

    private
    def define_and_mixin_gagged_attributes_methods
      return if @gagged_attributes_methods

      undefine_gagged_attributes_methods
    end

    def define_not_gagged_interpellations attributes, callable, options = nil
      unsanitized_values = lambda { |it|
        attributes.inject({}) do |a, attribute|
          a[attribute] = it.send(attribute)
          a
        end
      }

      output = 1 == attributes.length ?
        lambda { |it, attr| unsanitized_values.call(it)[attr] } :
        lambda { |it, attr| unsanitized_values.call(it) }

      fn = nil
      if options
        if 1 == callable.arity
          fn = lambda do |it, attr|
            callable.call(output.call(it, attr))
          end
        elsif 2 == callable.arity
          fn = lambda do |it, attr|
            callable.call(output.call(it, attr), options)
          end
        else
          fn = lambda do |it, attr|
            callable.call(output.call(it, attr), it, options)
          end
        end
      else
        if 1 == callable.arity
          fn = lambda do |it, attr|
            callable.call(output.call(it, attr))
          end
        else
          fn = lambda do |it, attr|
            callable.call(output.call(it, attr), it)
          end
        end
      end

      attributes.each do |attr|
        @gagged_attributes_methods.send(:define_method,
          gagged_attribute_negative_interpellation_name(attr)) do
            @gagged_attribute_results ||= {}

            # Have we performed this call already?
            unless @gagged_attribute_results.has_key?(attributes)
              @gagged_attribute_results[attributes] = fn.call(self, attr)
            end

            call_result = @gagged_attribute_results[attributes]

            if 1 == attributes.length
              # If only one attribute was supplied, a simple
              # boolean response is sufficient
              return false unless call_result
              return true unless call_result.respond_to?(:[])
            else
              raise BadResultsMappingError unless call_result.respond_to?(:[])
            end

            @gagged_attribute_results[attributes][attr]
          end
      end
    end

    def define_gagged_interpellation attribute
      neg_method = gagged_attribute_negative_interpellation_name(attribute)
      @gagged_attributes_methods.send(:define_method,
        gagged_attribute_interpellation_name(attribute)) do
          !method(neg_method).call
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

