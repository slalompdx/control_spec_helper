# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'control_spec_helper/version'

Gem::Specification.new do |s|
  s.name        = 'control_spec_helper'
  s.version     = ControlSpecHelper::Version::STRING
  s.authors     = ['Slalom Consulting']
  s.email       = ['eric.shamow@slalom.com']
  s.homepage    = 'http://github.com/eshamow/control_spec_helper'
  s.summary     = 'Standard tasks and configuration for control repo spec tests'
  s.description = 'Contains rake tasks and a standard spec_helper for running'\
                  ' spec tests on puppet control repo'
  s.licenses    = 'Apache-2.0'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f|
    File.basename(f)
  }

  # Runtime dependencies, but also probably dependencies of requiring projects
  s.add_runtime_dependency 'rake', '~> 11.1', '>= 11.1.2'
  s.add_runtime_dependency 'rspec-puppet', '~> 2.4'
  s.add_runtime_dependency 'puppet-lint', '~> 1.1'
  s.add_runtime_dependency 'puppet-syntax', '~> 2.1'
  s.add_runtime_dependency 'mocha', '~> 1.1'
  s.add_development_dependency 'pry', '~> 0.10'
end
