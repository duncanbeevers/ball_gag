class GaggedValidator < ActiveModel::EachValidator
  def validate_each object, attribute, value
    unless object.method(condition_method_name(attribute)).call
      object.errors[attribute] << (options[:message] || default_message)
    end
  end

  private
  def condition_method_name attribute
    "#{attribute}_#{BallGag.preterite}?"
  end

  def default_message
    "is not #{BallGag.preterite}"
  end
end

class NotGaggedValidator < GaggedValidator
  private
  def condition_method_name attribute
    "#{attribute}_not_#{BallGag.preterite}?"
  end

  def default_message
    "is #{BallGag.preterite}"
  end
end

