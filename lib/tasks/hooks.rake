# lib/tasks/hooks.rb

desc 'install or update pre-commit hook'
task :hooks do
  include FileUtils
  puts 'Installing pre-commit hook'
  hook = File.join(project_root, 'scripts', 'pre-commit')
  dest = File.join(project_root, '.git', 'hooks', 'pre-commit')
  FileUtils.cp hook, dest
  FileUtils.chmod 'a+x', dest
end
