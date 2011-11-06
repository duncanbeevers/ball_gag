class NotGaggedValidator < ActiveModel::EachValidator
  def validate_each object, attribute, value
    if object.method("#{attribute}_gagged?").call
      object.errors[attribute] << (options[:message] || 'is gagged')
    end
  end
end

