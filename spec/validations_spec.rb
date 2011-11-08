require 'spec_helper'

describe 'ActiveModel::Validations integration' do
  before do
    ExampleActiveModel.reset_callbacks :validate
    ExampleActiveModel.clear_gagged_attributes
  end

  describe NotGaggedValidator do
    it 'should call #{attribute}_gagged?' do
      ExampleActiveModel.validates :words, not_gagged: true

      instance = ExampleActiveModel.new
      instance.should_receive(:words_not_gagged?)
      instance.valid?
    end

    it 'should add default error message' do
      ExampleActiveModel.validates :words, not_gagged: true
      instance = ExampleActiveModel.new
      instance.stub!(words_not_gagged?: false)
      instance.valid?
      instance.errors[:words].should include 'is gagged'
    end

    it 'should respect custom error message' do
      ExampleActiveModel.validates :words,
        not_gagged: { message: 'is not acceptable' }
      instance = ExampleActiveModel.new
      instance.stub!(words_not_gagged?: false)
      instance.valid?
      instance.errors[:words].should include 'is not acceptable'
    end
  end

  describe GaggedValidator do
    it 'should add default error message' do
      ExampleActiveModel.validates :words, gagged: true
      instance = ExampleActiveModel.new
      instance.stub!(words_gagged?: false)
      instance.valid?
      instance.errors[:words].should include 'is not gagged'
    end
  end
end

