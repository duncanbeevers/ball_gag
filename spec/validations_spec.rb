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
  before { ExampleActiveModel.reset_callbacks :validate }

  it 'delegates to gag' do
    ExampleActiveModel.should_receive(:gag).
      and_return([])
    ExampleActiveModel.validates_gag :words
  end

  it 'adds validation on gagged attribtue' do
    ExampleActiveModel.validates_gag :words
    instance = ExampleActiveModel.new
    instance.should_receive(:words_gagged?).
      and_return(true)
    instance.valid?
  end

  it 'is not valid if attribute is gagged' do
    ExampleActiveModel.validates_gag :words
    instance = ExampleActiveModel.new
    instance.should_receive(:words_gagged?).
      and_return(true)
    instance.should_not be_valid
  end
end

