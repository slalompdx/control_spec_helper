# lib/tasks/apply.rb

desc 'run puppet apply (enforce mode)'
task apply: [:r10k] do
  puts "Running 'puppet apply'"
  exec puppet_cmd
end
