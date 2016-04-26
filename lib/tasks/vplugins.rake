# lib/tasks/vplugins.rb

desc 'install Vagrant plugins'
task :vplugins do
  `unset RUBYLIB ; vagrant plugin install vagrant-auto_network vagrant-hosts`
end
