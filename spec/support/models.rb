class ExampleModel
  include BallGag

  def words
    'Never has one man rocked so many.'
  end

  def email
    'theodore@example.com'
  end
end

class ExampleActiveModel
  include ActiveModel::Validations
  include BallGag

  def words
    'Welcome to the place where all the creatures meet.'
  end
end

class ExampleEngine
  class << self
    def call value, options = {}
      true
    end
  end
end

