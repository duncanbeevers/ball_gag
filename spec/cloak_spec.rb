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

  it 'should have non-negative preterite' do
    BallGag.preterite_negative?.should be_false
  end

  it 'should accept negative preterite' do
    BallGag.negative_preterite = 'acceptable'
    BallGag.preterite_negative?.should be_true
  end

  context 'when preterite is negative' do
    it 'should invert meaning of #{attribute}_#{preterite}?' do
      BallGag.negative_preterite = 'acceptable'
      ExampleModel.gag(:words) { |words| true }
      ExampleModel.new.words_acceptable?.should be_true
    end

    it 'should invert meaning of #{attribute}_not_#{preterite}?' do
      BallGag.negative_preterite = 'acceptable'
      ExampleModel.gag(:words) { |words| true }
      ExampleModel.new.words_not_acceptable?.should be_false
    end
  end
end

