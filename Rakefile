require 'rake'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'git'

task :default do
  sh %(rake -T)
end

require 'fileutils'

RSpec::Core::RakeTask.new(:spec)
Rake::Task[:spec].enhance ['fixtures:prep']

def version
  require 'control_spec_helper/version'
  ControlSpecHelper::Version::STRING
end

namespace :package do
  desc 'Create the gem'
  task :gem do
    spec = Gem::Specification.load('control_spec_helper.gemspec')
    begin
      Dir.mkdir('pkg')
    rescue => e
      puts e
    end
    if Gem::Version.new(`gem -v`) >= Gem::Version.new('2.0.0.a')
      Gem::Package.build(spec)
    else
      Gem::Builder.new(spec).build
    end
    FileUtils.move("control_spec_helper-#{version}.gem", 'pkg')
  end
end

desc 'Run rubocop against tree'
task :rubocop do
  puts `rubocop`
end

desc 'Cleanup pkg directory'
task :clean do
  FileUtils.rm_rf('pkg')
end

namespace :fixtures do
  desc 'Prepare fixtures directory'
  task :create do
    FileUtils.mkdir('fixtures') unless File.directory?('fixtures')
  end

  desc 'Remove fixtures directory'
  task :clean do
    FileUtils.rm_rf('fixtures')
  end

  desc 'Prepare fixtures repository'
  task prep: [:create] do
    begin
      unless File.exist?('fixtures/puppet-control')
        Git.clone('https://github.com/slalompdx/puppet-control.git',
                  'puppet-control',
                  path: 'fixtures',
                  branch: 'fixture')
        Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
          `bundle config local.control_spec_helper ../..`
          puts `bundle install`
        end
      end
    ensure
      `bundle config --delete local.control_spec_helper`
    end
  end
end
