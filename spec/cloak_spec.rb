require 'spec_helper'

describe 'BallGag cloaking' do
  before { BallGag.verb = nil }

  it 'should have default verb' do
    BallGag.verb.should eq 'gag'
  end

  it 'should accept new verb' do
    BallGag.verb = 'censor'
    BallGag.verb.should eq 'censor'
  end
end

