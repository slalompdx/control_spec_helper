require 'fileutils'

module ControlSpecHelper
  module Generate
    def self.skeleton
      dirs = [
        File.join('site', ''),
        File.join('site', 'profile', ''),
        File.join('site', 'role', ''),
        File.join('site', 'profile', 'manifests', ''),
        File.join('site', 'profile', 'spec', ''),
        File.join('site', 'role', 'manifests', ''),
        File.join('site', 'role', 'spec', '')
      ]

      files = {
        '.gitignore' => <<-HEREDOC,
.bundle/
.vagrant/
HEREDOC
        'Puppetfile' => <<-HEREDOC,
mod 'puppetlabs/stdlib'
HEREDOC
        'Rakefile' => <<-HEREDOC,
require 'control_spec_helper/control_spec_helper'
require 'control_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

include ControlSpecHelper
HEREDOC

        File.join('site', 'profile', 'spec', 'spec_helper.rb') => <<-HEREDOC,
require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
HEREDOC

        File.join('site', 'role', 'spec', 'spec_helper.rb') => <<-HEREDOC,
require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
HEREDOC
      }

      cwd = Dir.pwd
      answer = ''

      until answer =~ /ye?s?/i
        print "Create control repo skeleton in #{cwd}? (yN) "
        answer = $stdin.gets.chomp
        abort 'Exiting...' if answer =~ /no?/i || answer.empty?
      end

      puts 'Creating skeleton...'

      dirs.each do |path|
        Dir.chdir(cwd) { FileUtils.mkdir_p(path) }
      end

      files.each do |path, content|
        Dir.chdir(cwd) do
          f = File.new(path, 'w')
          f.puts content
          f.close
        end
      end
    end
  end
end
