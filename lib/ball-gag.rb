require 'ball-gag/version'

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

    def gag attribute, callable = nil, &block
      define_and_mixin_gagged_attributes_methods
      @gagged_attributes[attribute] = callable || block || lambda { |*| }

      define_gagged_interpellation attribute, @gagged_attributes[attribute]
      define_not_gagged_interpellation attribute
    end

    def clear_gagged_attributes
      undefine_gagged_attributes_methods
    end

    private
    def define_and_mixin_gagged_attributes_methods
      return if @gagged_attributes_methods

      undefine_gagged_attributes_methods
    end

    def define_gagged_interpellation attribute, block
      callable = @gagged_attributes[attribute]
      @gagged_attributes_methods.send(:define_method,
        gagged_attribute_interpellation_name(attribute)) do
          callable.call({ attribute => self.send(attribute) }, self)
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

