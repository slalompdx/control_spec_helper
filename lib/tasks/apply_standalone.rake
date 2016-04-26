# lib/tasks/apply_standalone.rb

desc 'run puppet apply (no r10k or git)'
task :apply_standalone do
  puts "Running 'puppet apply'"
  exec "#{puppet_cmd} --debug --trace"
end
