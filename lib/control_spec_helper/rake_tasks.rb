require 'puppet-lint/tasks/puppet-lint'
Dir.glob("#{File.dirname(__FILE__)}/../tasks/**/*.rb").each { |f| import f }
