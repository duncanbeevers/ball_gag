require 'spec_helper'

describe 'Plain Old Ruby Object' do
  before { ExampleModel.clear_gagged_attributes }

  it 'should have no gagged attributes' do
    ExampleModel.gagged_attributes.should be_empty
  end

  it 'should gag attribute' do
    ExampleModel.gag :words
    ExampleModel.gagged_attributes.should include :words
  end

  describe 'when clearing gagged attributes' do
    it 'should clear gagged attributes' do
      ExampleModel.gag :words
      ExampleModel.clear_gagged_attributes
      ExampleModel.gagged_attributes.should == []
    end

    it 'should remove attribute_not_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to(:words_not_gagged?)
      ExampleModel.clear_gagged_attributes
      ExampleModel.new.should_not respond_to(:words_not_gagged?)
    end

    it 'should remove attribute_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to(:words_gagged?)
      ExampleModel.clear_gagged_attributes
      ExampleModel.new.should_not respond_to(:words_gagged?)
    end
  end

  it 'should add new attribute_gagged? method' do
    ExampleModel.gag :words
    ExampleModel.new.should respond_to :words_gagged?
  end

  it 'should add new attribute_not_gagged? method' do
    ExampleModel.gag :words
    ExampleModel.new.should respond_to :words_not_gagged?
  end

  context 'when gagged with a callable' do
    it 'should call callable when checking whether attribute is gagged' do
      callable = {}
      ExampleModel.gag :words, callable
      instance = ExampleModel.new
      attribute_value = instance.words

      callable.should_receive(:call).with(
        hash_including(words: attribute_value), instance)
      instance.words_gagged?
    end

    it 'should call block when checking whether attribute is gagged' do
      a = nil
      b = nil
      ExampleModel.gag :words do |unsanitized_values, instance|
        a = unsanitized_values
        b = instance
      end
      instance = ExampleModel.new
      attribute_value = instance.words

      instance.words_gagged?

      a.should have_key(:words)
      a[:words].should eq attribute_value

      b.should eq instance
    end

    it 'should return true for attribute_not_gagged? if callable returns true' do
      ExampleModel.gag :words do |*| false end
      ExampleModel.new.words_not_gagged?.should be_true
    end

    it 'should return false for attribute_not_gagged? if callable returns true' do
      ExampleModel.gag :words do |*| false end
      ExampleModel.new.words_gagged?.should be_false
    end
  end
end

