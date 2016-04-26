# lib/tasks/apply_dev.rb

desc 'run puppet apply (no git)'
task apply_dev: :r10k do
  puts "Running 'puppet apply'"
  exec puppet_cmd
end
