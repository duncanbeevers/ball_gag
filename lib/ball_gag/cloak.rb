module BallGag
  module Cloak
    def verb
      @verb || 'gag'
    end

    def verb= verb
      @verb = verb
    end
  end

  extend Cloak
end

