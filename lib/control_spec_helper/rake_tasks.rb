require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

task :default => [:help]

desc 'update repo from origin (destructive)'
task :git do
  puts 'Updating puppet-control repo'
  `git fetch --all`
  `git checkout --track origin/cloud`
  `git reset --hard origin/cloud`
end

desc 'install all modules from the Puppetfile (idempotent)'
task :r10k do
  r10k
end

desc 'run puppet apply (enforce mode)'
task :apply => [:git, :r10k] do
  puts "Running 'puppet apply'"
  exec puppet_cmd
end

desc 'run puppet apply (no git)'
task :apply_dev => :r10k do
  puts "Running 'puppet apply'"
  exec puppet_cmd
end

desc 'run puppet apply (noop)'
task :apply_noop do
  puts "Running 'puppet apply'"
  exec "#{puppet_cmd} --noop"
end

desc 'run puppet apply (debug)'
task :apply_debug do
  puts "Running 'puppet apply'"
  exec "#{puppet_cmd} --debug --trace"
end

desc 'install or update pre-commit hook'
task :hooks do
  include FileUtils
  puts 'Installing pre-commit hook'
  hook = File.join(project_root, 'scripts', 'pre-commit')
  dest = File.join(project_root, '.git', 'hooks', 'pre-commit')
  FileUtils.cp hook, dest
  FileUtils.chmod 'a+x', dest
end

desc 'install Vagrant plugins'
task :vplugins do
  exec 'vagrant plugin install vagrant-auto_network vagrant-hosts'
end

desc 'prep for spec tests'
task :spec_prep do
  r10k
  profile_fixtures
end

desc 'run unit tests'
task :spec do
  Rake::Task['spec_prep'].invoke
  Dir.chdir(profile_path) do
    system 'bundle exec rake rspec'
  end
  Rake::Task['spec_clean'].invoke
end

desc 'clean up after unit tests'
task :spec_clean do
  spec_clean
end

desc 'Run acceptance tests for 1 or more roles'
task :acceptance do
  Rake::Task['spec_clean'].invoke

  role = if ENV['role'] || ENV['roles']
           (ENV['role'] || ENV['roles']).split(',')
         elsif !diff_roles.empty?
           diff_roles
         else
           puts 'no roles specified and no changes detected'
           exit 0
         end

  puts "-- Acceptance tests for #{role.join(', ')} --"
  paths = role.map do |klass|
    if klass.match(%r{^role})
      spec_from_class(klass)
    else
      spec_from_class("role::#{klass}")
    end
  end.join(' ')
  Dir.chdir(role_path) do
    abort unless
      system "bash -c 'bundle exec rspec --format documentation #{paths}'"
  end
end

desc 'Run acceptance tests locally from SUT'
task :serverspec do
  Dir.chdir(role_path) do
    if ENV['role']
      role_spec = ENV['role']
    else
      role_spec = `facter role`.chomp.split('::').join('/')
    end
    ENV['serverspec'] = 'true'
    system "rspec spec/acceptance/#{role_spec}_spec.rb"
  end
end

# Override default puppet-lint choices
# Must clear as it will not override the existing puppet-lint rake task since we require to import for
# the PuppetLint::RakeTask
Rake::Task[:lint].clear
# Relative is not able to be set within the context of PuppetLint::RakeTask                          PuppetLint.configuration.relative = true
PuppetLint::RakeTask.new(:lint) do |config|
  config.fail_on_warnings = true
  config.disable_checks = [
      '80chars',
      'class_inherits_from_params_class',
      'class_parameter_defaults',
      'documentation',
      'single_quote_string_with_variables']
  config.ignore_paths = ["tests/**/*.pp", "vendor/**/*.pp","examples/**/*.pp", "spec/**/*.pp", "pkg/**/*.pp"]
end

desc "Display the list of available rake tasks"
task :help do
    system("rake -T")
end
