# lib/tasks/vplugins.rb

desc 'install Vagrant plugins'
task :vplugins do
  Bundler.with_clean_env do
    puts 'Installing plugins...'
    `unset RUBYLIB ; vagrant plugin install vagrant-auto_network vagrant-hosts`
  end
end
