Dir.glob("#{File.dirname(__FILE__)}/../lib/tasks/**/*.rb")
   .each { |f| require f }
Dir.glob("#{File.dirname(__FILE__)}/support/shared_contexts/**/*.rb")
   .each { |f| require f }
