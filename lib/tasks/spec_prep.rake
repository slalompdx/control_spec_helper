# lib/tasks/spec_prep.rb

include ControlSpecHelper

desc 'prep for spec tests'
task :spec_prep do
  r10k
  profile_fixtures
end
