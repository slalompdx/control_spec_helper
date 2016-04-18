require 'control_spec_helper/control_spec_helper'
$stderr.puts 'debugging code'
Dir["./lib/tasks/**/*.rb"].sort.each { |f| include f }
