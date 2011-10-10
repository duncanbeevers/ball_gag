class ExampleModel
  include BallGag

  def words
    'Never has one man rocked so many.'
  end
end

class ExampleActiveModel
  include ActiveModel::Validations
  include BallGag

  validate :words_not_gagged?

  def words
    'Welcome to the place where all the creatures meet.'
  end
end

