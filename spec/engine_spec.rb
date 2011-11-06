require 'spec_helper'

describe BallGag do
  before { BallGag.engine = nil }

  it 'should have no engine' do
    BallGag.engine.should be_nil
  end

  it 'should have configurable engine' do
    mock_engine = mock('engine')
    BallGag.engine = mock_engine
    BallGag.engine.should eq mock_engine
  end

  it 'should use engine' do
    BallGag.engine = ExampleEngine
    ExampleModel.gag :words, { strict: true }
    ExampleModel.new.words_gagged?.should be_false
  end
end

