# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "control_spec_helper/version"

Gem::Specification.new do |s|
  s.name        = "control_spec_helper"
  s.version     = ControlSpecHelper::Version::STRING
  s.authors     = ["Slalom Consulting"]
  s.email       = ["eric.shamow@slalom.com"]
  s.homepage    = "http://github.com/eshamow/control_spec_helper"
  s.summary     = "Standard tasks and configuration for control repo spec tests"
  s.description = "Contains rake tasks and a standard spec_helper for running spec tests on puppet control repo"
  s.licenses    = 'Apache-2.0'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  # Runtime dependencies, but also probably dependencies of requiring projects
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'rspec-puppet'
  s.add_runtime_dependency 'puppet', ">= 4.0"
  s.add_runtime_dependency 'puppet-lint'
  s.add_runtime_dependency 'puppet-syntax'
  s.add_runtime_dependency 'mocha'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'git'
  s.add_development_dependency 'rubocop'
end
