# lib/tasks/spec.rb

desc 'run profile unit tests'
task :unit do
  success = false
  Rake::Task['spec_prep'].invoke
  Dir.chdir(profile_path) do
    rspec = 'bundle exec rspec'
    spec_pattern = 'spec/**/*_spec.rb'
    exclude = 'spec/{fixtures,acceptance}/*_spec.rb'
    success = system "#{rspec} -P \"#{spec_pattern}\" --exclude-pattern \"#{exclude}\""
  end
  Rake::Task['spec_clean'].invoke
  abort unless success
end
