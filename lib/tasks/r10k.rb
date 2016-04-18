# lib/tasks/r10k.rb

desc 'install all modules from the Puppetfile (idempotent)'
task :r10k do
  r10k
end
