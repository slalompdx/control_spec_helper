require 'rake'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'git'
require 'net/ssh'
require 'English'
require 'control_spec_helper/util'

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

  task :shared_prep do
    unless File.exist?('fixtures/puppet-control')
      puts 'Cloning puppet_control repository...'
      Git.clone('https://github.com/slalompdx/puppet-control.git',
                'puppet-control',
                path: 'fixtures',
                branch: 'fixture')
    end
  end

  desc 'Remove fixtures directory'
  task :clean do
    if File.exist?('fixtures/puppet-control')
      Dir.chdir('fixtures/puppet-control') do
        `unset RUBYLIB ; vagrant destroy -f`
      end
    end
    FileUtils.rm_rf('fixtures')
  end

  desc 'Bring up test vm'
  task vm: [:create, 'package:gem', :shared_prep] do
    Bundler.with_clean_env do
      Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
        puts 'Bringing up test VM...'
        IO.popen('unset RUBYLIB ; vagrant up') do |io|
          io.each { |s| print s }
        end
      end
    end
  end

  desc 'Copy built gem into fixtures directory'
  task copy_gem: [:create, 'package:gem', :shared_prep] do
    Bundler.with_clean_env do
      Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
        puts 'Copying control_spec_helper into fixtures'
        FileUtils.mkdir_p('./vendor/cache') unless File.exist?('./vendor/cache')
        FileUtils.mkdir_p('./vendor/gems') unless File.exist?('./vendor/gems')
        FileUtils.cp("../../pkg/control_spec_helper-#{version}.gem",
                     './vendor/cache')
        `gem unpack \
          ./vendor/cache/*.gem \
          --target=./fixtures/puppet-control/vendor/gems/`
      end
    end
  end

  desc 'Install control_spec_helper gem on client vm'
  task install_gem: [:copy_gem] do
    Bundler.with_clean_env do
      Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
        connection = build_vagrant_connection(vagrant_ssh_config)
        puts 'Installing control_spec_helper gem...'
        ssh_exec!(
          connection,
          'cd /vagrant && gem install ./vendor/cache/*.gem --no-ri --no-rdoc'
        )
        connection.close
      end
    end
  end

  desc 'Run bundle install on client vm'
  task bundle_install: [:install_gem] do
    Bundler.with_clean_env do
      Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
        connection = build_vagrant_connection(vagrant_ssh_config)
        puts 'Running bundle install...'
        ssh_exec!(connection, 'cd /vagrant && bundle install --path=vendor/')
        connection.close
      end
    end
  end

  desc 'Install vagrant on client vm'
  task install_vagrant: [:vm] do
    Bundler.with_clean_env do
      Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
        connection = build_vagrant_connection(vagrant_ssh_config)
        response = ssh_exec!(connection, 'rpm -qa | grep vagrant')
        if response[2] != 0
          puts 'Installing vagrant...'
          ssh_exec!(
            connection,
            'sudo rpm -ivh https://releases.hashicorp.com/'\
            'vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm'
          )
        else
          puts 'Skipping vagrant install, already present...'
        end
      end
    end
  end

  desc 'Link puppet binary on client vm'
  task link_puppet: [:vm] do
    Bundler.with_clean_env do
      Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
        connection = build_vagrant_connection(vagrant_ssh_config)
        puts 'Linking puppet binary...'
        ssh_exec!(connection,
                  'sudo ls /usr/bin/puppet || '\
                  'sudo ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet'
                 )
        connection.close
      end
    end
  end

  desc 'Run r10k on client vm'
  task run_r10k: [:vm] do
    Bundler.with_clean_env do
      Dir.chdir("#{File.dirname(__FILE__)}/fixtures/puppet-control") do
        connection = build_vagrant_connection(vagrant_ssh_config)
        puts 'Running r10k on vm...'
        ssh_exec!(connection,
                  'cd /vagrant ; bundle exec rake r10k')
        connection.close
      end
    end
  end
  desc 'Convenience method - Update gem on existing vm'
  task :update_gem do
    Rake::Task['package:gem'].invoke
    Rake::Task['fixtures:copy_gem'].invoke
    Rake::Task['fixtures:install_gem'].invoke
    Rake::Task['fixtures:bundle_install'].invoke
  end

  desc 'Prepare fixtures repository'
  task prep: [:create, 'package:gem', :shared_prep] do
    Rake::Task['fixtures:vm'].invoke
    Rake::Task['fixtures:copy_gem'].invoke
    Rake::Task['fixtures:install_gem'].invoke
    Rake::Task['fixtures:bundle_install'].invoke
    Rake::Task['fixtures:install_vagrant'].invoke
    Rake::Task['fixtures:link_puppet'].invoke
    Rake::Task['fixtures:run_r10k'].invoke
  end
end

desc 'Execute unit tests'
task unit: ['fixtures:shared_prep'] do
  exec 'bundle exec rspec -P spec/unit/*_spec.rb'
end

desc 'Execute acceptance tests'
task acceptance: ['fixtures:prep'] do
  exec 'bundle exec rspec -P spec/tasks/*_spec.rb'
end
