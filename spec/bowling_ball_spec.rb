require 'spec_helper'

describe BowlingBall do
  after { Kernel.send(:remove_const, :BowlingBallIncluder) }

  context 'when included' do
    it 'should include BallGag' do
      class Kernel::BowlingBallIncluder
        include BowlingBall
      end

      BowlingBallIncluder.included_modules.should include BallGag
    end
  end
end

