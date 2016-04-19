# lib/tasks/git.rb

desc 'update repo from origin (destructive)'
task :git do
  puts 'Updating puppet-control repo'
  `git fetch --all`
  `git checkout --track origin/cloud`
  `git reset --hard origin/cloud`
end
