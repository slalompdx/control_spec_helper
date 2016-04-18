require 'puppet-lint/tasks/puppet-lint'
Dir.glob(File.directory(__FILE__).join('tasks/**/*.rb').each { |f| import f }
