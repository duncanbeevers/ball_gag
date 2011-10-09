# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ball-gag/version'

Gem::Specification.new do |s|
  s.name        = 'ball-gag'
  s.version     = Ball::Gag::VERSION
  s.authors     = ['Duncan Beevers']
  s.email       = ['duncan@dweebd.com']
  s.homepage    = ''
  s.summary     = 'Pluggable Content Sanitization'
  s.description = 'Sanitize user input using with pluggable back-ends'

  s.rubyforge_project = 'ball-gag'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_development_dependency 'rspec'
end
