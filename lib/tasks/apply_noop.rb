# lib/tasks/apply_noop.rb

task :apply_noop do
  puts "Running 'puppet apply'"
  exec "#{puppet_cmd} --noop"
end
