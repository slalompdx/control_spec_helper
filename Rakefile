require 'rake'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'git'
require 'net/ssh'
require 'find'

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
  task prep: [:create, 'package:gem'] do
    begin
      unless File.exist?('fixtures/puppet-control')
        puts 'Cloning puppet_control repository...'
        Git.clone('https://github.com/slalompdx/puppet-control.git',
                  'puppet-control',
                  path: 'fixtures',
                  branch: 'fixture')
      end
      Bundler.with_clean_env do
        Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
          puts 'Copying control_spec_helper into fixtures'
          FileUtils.mkdir(
            "#{File.dirname(__FILE__)}/fixtures/puppet-control/csh"
          ) unless File.exist?(
            "#{File.dirname(__FILE__)}/fixtures/puppet-control/csh"
          )
          FileUtils.cp(
            "#{File.dirname(__FILE__)}/pkg/control_spec_helper-#{version}.gem",
            "#{File.dirname(__FILE__)}/fixtures/puppet-control/csh"
          )
          puts 'Bringing up test VM...'
          IO.popen('unset RUBYLIB ; vagrant up') do |io|
            io.each { |s| print s }
          end
          c = vagrant_ssh_config
          Net::SSH.start(
            c['HostName'],
            c['User'],
            port: c['Port'],
            password: 'vagrant'
          ) do |ssh|
            puts ssh.exec!(
              'cd /vagrant && gem install ./csh/*.gem --no-ri --no-rdoc'
            )
            puts ssh.exec!('cd /vagrant && bundle install')
            puts ssh.exec!('cd /vagrant && bundle exec rake -T')
          end
        end
      end
    ensure
      `bundle config --delete local.control_spec_helper`
    end
  end
end

def vagrant_ssh_config
  config = {}
  `vagrant ssh-config --machine-readable`.split(',')[7]
    .split('\n')[0..9].collect(&:lstrip)
    .each do |element|
      key, value = element.split(' ')
      config[key] = value
    end
  config
end
