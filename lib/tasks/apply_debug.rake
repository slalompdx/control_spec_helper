# lib/tasks/apply_debug.rb

desc 'run puppet apply (debug)'
task :apply_debug do
  puts "Running 'puppet apply'"
  exec "#{puppet_cmd} --debug --trace"
end
