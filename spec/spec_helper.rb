require 'spork'

Spork.prefork do
  require 'rspec'
  require 'active_model'
end

Spork.each_run do
  require 'ball-gag'
  require './spec/models'
end

