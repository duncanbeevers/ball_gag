require 'spork'

Spork.prefork do
  require 'rspec'
  require 'active_model'
end

Spork.each_run do
  require 'ball-gag'
  require File.join(File.dirname(__FILE__), 'support/models')
end

