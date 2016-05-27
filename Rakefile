require 'rake'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'git'
require 'net/ssh'
require 'English'
require './lib/slalom'

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
          FileUtils.mkdir_p("#{File.dirname(__FILE__)}/fixtures/"\
            'puppet-control/vendor/gems')
          `gem unpack \
            #{File.dirname(__FILE__)}/fixtures/puppet-control/csh/*.gem \
            --target=./fixtures/puppet-control/vendor/gems/`
          puts 'Bringing up test VM...'
          IO.popen('unset RUBYLIB ; vagrant up') do |io|
            io.each { |s| print s }
          end
          c = vagrant_ssh_config
          connection = Net::SSH.start(
            c['HostName'],
            c['User'],
            port: c['Port'],
            password: 'vagrant'
          )
          puts 'Installing control_spec_helper gem...'
          ssh_exec!(
            connection,
            'cd /vagrant && gem install ./csh/*.gem --no-ri --no-rdoc'
          )
          puts 'Running bundle install...'
          ssh_exec!(connection, 'cd /vagrant && bundle install')
          response = ssh_exec!(connection, 'rpm -qa | grep vagrant')
          if response[2] != 0
            puts 'Installing vagrant...'
            ssh_exec!(
              connection,
              'sudo rpm -ivh https://releases.hashicorp.com/'\
              'vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm')
          else
            puts 'Skipping vagrant install, already present...'
          end
          puts 'Linking puppet binary...'
          ssh_exec!(connection, 'sudo ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet')
          connection.close
        end
      end
    ensure
      `bundle config --delete local.control_spec_helper`
    end
  end
end
