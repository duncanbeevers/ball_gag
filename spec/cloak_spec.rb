require 'spec_helper'

describe 'BallGag cloaking' do
  before do
    ExampleModel.clear_gagged_attributes
    ExampleActiveModel.reset_callbacks :validate
    ExampleActiveModel.clear_gagged_attributes
    BallGag.verb = nil
    BallGag.preterite = nil
  end

  after do
    ExampleModel.clear_gagged_attributes
    ExampleActiveModel.clear_gagged_attributes
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

  describe 'validators' do
    specify 'custom preterite should create validator' do
      BallGag.preterite = 'censored'
      ExampleActiveModel.gag(:words) { |words| true }
      ExampleActiveModel.validates :words, censored: true
      instance = ExampleActiveModel.new
      instance.valid?
      instance.errors[:words].should include 'is not censored'
    end

    specify 'custom preterite should create Not validator' do
      BallGag.preterite = 'censored'
      ExampleActiveModel.gag(:words) { |words| false }
      ExampleActiveModel.validates :words, not_censored: true
      instance = ExampleActiveModel.new
      instance.valid?
      instance.errors[:words].should include 'is censored'
    end

    specify 'negative preterite should create inverse validator' do
      BallGag.negative_preterite = 'acceptable'
      ExampleActiveModel.gag(:words) { |words| false }
      ExampleActiveModel.validates :words, acceptable: true
      instance = ExampleActiveModel.new
      instance.valid?
      instance.errors[:words].should include 'is not acceptable'
    end

    specify 'negative preterite should alter message but not meaning of extant validators' do
      BallGag.negative_preterite = 'acceptable'

      ExampleActiveModel.gag(:words) { |words| false }
      ExampleActiveModel.validates :words, not_gagged: true
      instance = ExampleActiveModel.new
      instance.valid?
      instance.errors[:words].should include 'is not acceptable'
    end
  end

  describe BowlingBall do
    it 'should set verb' do
      BowlingBall.verb = 'censor'
      BallGag.verb.should eq 'censor'
    end

    it 'should set preterite' do
      BowlingBall.preterite = 'censored'
      BallGag.preterite.should eq 'censored'
    end

    it 'should set negative preterite' do
      BowlingBall.negative_preterite = 'acceptable'
      BallGag.preterite.should eq 'acceptable'
      BallGag.preterite_negative?.should be_true
    end

    it 'should set engine' do
      mock_engine = mock('engine')
      BowlingBall.engine = mock_engine
      BallGag.engine.should eq mock_engine
    end
  end
end

