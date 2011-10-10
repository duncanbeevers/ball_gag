require 'spec_helper'

describe 'Plain Old Ruby Object' do
  it 'should have no gagged attributes' do
    ActiveModelExample.gagged_attributes.should be_empty
  end

  it 'should gag attribute' do
    ActiveModelExample.gag :words
    ActiveModelExample.gagged_attributes.should include :words
  end

  it 'should clear gagged attributes' do
    ActiveModelExample.gag :words
    ActiveModelExample.clear_gagged_attributes
    ActiveModelExample.gagged_attributes.should == []
  end
end

