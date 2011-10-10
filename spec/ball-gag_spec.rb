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
  end
end

