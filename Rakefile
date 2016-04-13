require 'rake'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

task :default do
  sh %(rake -T)
end

require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

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
    rescue Errno::ENOENT => ex
      puts ex
      exit 1
    end
    if Gem::Version.new(`gem -v`) >= Gem::Version.new('2.0.0.a')
      Gem::Package.build(spec)
    else
      Gem::Builder.new(spec).build
    end
    FileUtils.move("control_spec_helper-#{version}.gem", 'pkg')
  end
end

desc 'Cleanup pkg directory'
task :clean do
  FileUtils.rm_rf('pkg')
end
