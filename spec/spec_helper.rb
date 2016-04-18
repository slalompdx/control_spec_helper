require 'rspec'
require 'rake'
require 'control_spec_helper'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f}
