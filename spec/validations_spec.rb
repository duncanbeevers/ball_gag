require 'spec_helper'

describe 'Include BallGag::Validations' do
  it 'adds validation methods' do
    class Foo
      include ActiveModel::Validations
      include BallGag
      include BallGag::Validations
    end

    Foo.should respond_to(:validates_gag)
  end
end

describe ExampleActiveModel do
  it 'delegates to gag' do
    ExampleActiveModel.should_receive(:gag)
    ExampleActiveModel.validates_gag :words
  end
end

