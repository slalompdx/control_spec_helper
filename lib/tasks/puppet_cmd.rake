# lib/tasks/puppet_cmd.rb

desc 'print the command used to run puppet'
task :puppet_cmd do
  puts puppet_cmd
end
