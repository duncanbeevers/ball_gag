require 'spec_helper'

describe 'BallGag cloaking' do
  before do
    ExampleModel.clear_gagged_attributes
    BallGag.verb = nil
    BallGag.preterite = nil
  end

  after do
    ExampleModel.clear_gagged_attributes
    BallGag.verb = nil
    BallGag.preterite = nil
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

  it 'should have preterite' do
    BallGag.preterite.should eq 'gagged'
  end

  it 'should accept new preterite' do
    BallGag.preterite = 'censored'
    BallGag.preterite.should eq 'censored'
  end

  it 'should define #{attribute}_#{preterite}? method on instance' do
    BallGag.preterite = 'censored'
    ExampleModel.gag :words
    ExampleModel.new.should respond_to :words_censored?
  end

  it 'should define #{attribute}_not_#{preterite}? method on instance' do
    BallGag.preterite = 'censored'
    ExampleModel.gag :words
    ExampleModel.new.should respond_to :words_not_censored?
  end
end

