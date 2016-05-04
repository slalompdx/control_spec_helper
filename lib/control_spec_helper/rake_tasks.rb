require 'puppet-lint/tasks/puppet-lint'
Dir.glob("#{File.dirname(__FILE__)}/../tasks/**/*.rake").each { |f| import f }
