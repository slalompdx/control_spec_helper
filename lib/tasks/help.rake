# lib/tasks/help.rb

desc 'Display the list of available rake tasks'
task :help do
  system('rake -T')
end
