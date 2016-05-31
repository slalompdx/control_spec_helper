# lib/tasks/lint.rb

# Override default puppet-lint choices
# Must clear as it will not override the existing puppet-lint rake task since
# we require to import for the PuppetLint::RakeTask
require 'puppet-lint/tasks/puppet-lint'

#Rake::Task[:lint].clear
# Relative is not able to be set within the context of PuppetLint::RakeTask
PuppetLint.configuration.ignore_paths = ['tests', 'vendor', 'examples', 'spec', 'pkg', 'modules']
