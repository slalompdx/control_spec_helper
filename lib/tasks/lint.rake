# lib/tasks/lint.rb

# Override default puppet-lint choices
# Must clear as it will not override the existing puppet-lint rake task since
# we require to import for the PuppetLint::RakeTask
require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear if Rake::Task.task_defined? :lint
# Relative is not able to be set within the context of PuppetLint::RakeTask
PuppetLint.configuration.relative = true
PuppetLint::RakeTask.new(:lint) do |config|
  config.fail_on_warnings = true
  config.disable_checks = %w(
    80chars
    class_inherits_from_params_class
    class_parameter_defaults
    documentation
  )
  config.ignore_paths = %w(
    tests/**/*.pp
    vendor/**/*.pp
    examples/**/*.pp
    spec/**/*.pp
    pkg/**/*.pp
    modules/**/**/*.pp
  )
end
