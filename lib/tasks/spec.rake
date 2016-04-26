# lib/tasks/spec.rb

desc 'run unit tests'
task :spec do
  Rake::Task['spec_prep'].invoke
  Dir.chdir(profile_path) do
    system 'bundle exec rake rspec'
  end
  Rake::Task['spec_clean'].invoke
end
