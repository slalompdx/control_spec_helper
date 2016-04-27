# lib/tasks/spec_prep.rb

include ControlSpecHelper

desc 'prep for spec tests'
task :spec_prep do
  r10k
  puts "====== #{project_root}"
  profile_fixtures
end
