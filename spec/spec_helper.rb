require 'spork'

Spork.prefork do
  require 'rspec'
  require 'active_model'
  require 'pry-remote'
end

Spork.each_run do
  require 'ball_gag'
  require File.join(File.dirname(__FILE__), 'support/models')
end

