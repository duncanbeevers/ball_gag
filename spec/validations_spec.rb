require 'spec_helper'

describe 'ActiveModel::Validations integration' do
  before do
    ExampleActiveModel.reset_callbacks :validate
    ExampleActiveModel.clear_gagged_attributes
    BallGag.only_validate_on_attribute_changed = false
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

    it 'should respect :allow_blank option' do
      mock_words = mock('words')

      ExampleActiveModel.gag(:words) { |words| false }
      ExampleActiveModel.validates :words,
        not_gagged: { allow_blank: true }

      instance = ExampleActiveModel.new
      instance.stub!(words: mock_words)
      mock_words.should_receive(:blank?).
        and_return(true)

      instance.should_not_receive(:words_not_gagged?)
      instance.valid?
    end

    context 'when configured to only check on attribute changed' do
      before { BallGag.only_validate_on_attribute_changed = true }

      it 'should not call #{attribute}_not_gagged? if attribute is not changed' do
        callable = lambda {}
        ExampleActiveModel.gag :words, callable
        ExampleActiveModel.validates :words,
          not_gagged: true

        instance = ExampleActiveModel.new
        instance.should_not be_words_changed

        callable.should_not_receive(:call)
        instance.valid?
      end
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

