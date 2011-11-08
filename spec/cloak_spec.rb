require 'spec_helper'

describe 'BallGag cloaking' do
  before do
    BallGag.verb = nil
    ExampleModel.clear_gagged_attributes
  end

  it 'should have default verb' do
    BallGag.verb.should eq 'gag'
  end

  it 'should accept new verb' do
    BallGag.verb = 'censor'
    BallGag.verb.should eq 'censor'
  end

  it 'should provide verb as class method' do
    BallGag.verb = 'censor'
    ExampleModel.should respond_to :censor
  end

  it 'should gag attribute when custom verb is used' do
    BallGag.verb = 'censor'
    ExampleModel.censor :words
    ExampleModel.gagged_attributes.should include :words
  end

  it 'should remove custom verb method when verb is cleared' do
    BallGag.verb = 'censor'
    BallGag.verb = nil
    ExampleModel.should_not respond_to :censor
  end
end

