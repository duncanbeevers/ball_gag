module BallGag
  def self.included base
    @gagged_inclusions ||= {}
    if !@gagged_inclusions[base]
      @gagged_inclusions[base] = true
      base.extend ClassMethods
    end
  end

  def invalidate_gag_cache attributes
    @gagged_attribute_results.delete(attributes)
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

    def define_not_gagged_interpellations attributes, callable, gag_options = nil
      one_attribute = 1 == attributes.length
      unsanitized_values = lambda { |it|
        attributes.inject({}) do |a, attribute|
          a[attribute] = it.send(attribute)
          a
        end
      }

      output = one_attribute ?
        lambda { |it, attr| unsanitized_values.call(it)[attr] } :
        lambda { |it, attr| unsanitized_values.call(it) }

      arity = callable.respond_to?(:arity) ?
        callable.arity :
        callable.method(:call).arity.abs

      fn = nil
      if 1 == arity
        fn = lambda { |it, attr| callable.call(output.call(it, attr)) }
      else
        fn = lambda do |it, attr|
          callable.call(output.call(it, attr),
            { options: gag_options,
              instance: it,
              attr: attr,
              single: one_attribute
            })
          end
      end

      attributes.each do |attr|
        @gagged_attributes_methods.send(:define_method,
          gagged_attribute_negative_interpellation_name(attr)) do
            return true unless BallGag.enabled?

            @gagged_attribute_results ||= {}

            # Is the attribute dirty?
            any_changed = attributes.any? do |attribute|
              dirty_method_name = "#{attribute}_changed?"
              respond_to?(dirty_method_name) &&
                method(dirty_method_name).call
            end

            # Have we performed this call already?
            if any_changed || !@gagged_attribute_results.has_key?(attributes)
              @gagged_attribute_results[attributes] = fn.call(self, attr)
            end

            call_result = @gagged_attribute_results[attributes]

            if one_attribute
              # If only one attribute was supplied, a simple
              # boolean response is sufficient
              return unless call_result
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
      gagged_attribute_preterite_interpellation_name(
        attribute, !BallGag.preterite_negative?)
    end

    def gagged_attribute_negative_interpellation_name attribute
      gagged_attribute_preterite_interpellation_name(
        attribute, BallGag.preterite_negative?)
    end

    def gagged_attribute_preterite_interpellation_name attribute, negative
      negative ?
        "#{attribute}_#{BallGag.preterite}?" :
        "#{attribute}_not_#{BallGag.preterite}?"
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

