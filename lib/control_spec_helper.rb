require 'control_spec_helper/control_spec_helper'
puts "HALLO"
Dir["./lib/tasks/**/*.rb"].sort.each { |f| require f ; puts f}
