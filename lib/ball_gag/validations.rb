class GaggedValidator < ActiveModel::EachValidator
  def validate_each object, attribute, value
    unless object.method(condition_method_name(attribute)).call
      object.errors[attribute] << (options[:message] || default_message)
    end
  end

  private
  def condition_method_name attribute
    BallGag.preterite_negative? ?
      neg_method_name(attribute) :
      pos_method_name(attribute)
  end

  def default_message
    BallGag.preterite_negative? ?
      "is #{BallGag.preterite}" :
      "is not #{BallGag.preterite}"
  end

  def neg_method_name attribute
    "#{attribute}_not_#{BallGag.preterite}?"
  end

  def pos_method_name attribute
    "#{attribute}_#{BallGag.preterite}?"
  end
end

class NotGaggedValidator < GaggedValidator
  private
  def condition_method_name attribute
    BallGag.preterite_negative? ?
      pos_method_name(attribute) :
      neg_method_name(attribute)
  end

  def default_message
    BallGag.preterite_negative? ?
      "is not #{BallGag.preterite}" :
      "is #{BallGag.preterite}"
  end
end

