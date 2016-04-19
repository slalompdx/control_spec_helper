# lib/tasks/acceptance.rb

desc 'Run acceptance tests for 1 or more roles'
task :acceptance do
  Rake::Task['spec_clean'].invoke

  role = if ENV['role'] || ENV['roles']
           (ENV['role'] || ENV['roles']).split(',')
         elsif !diff_roles.empty?
           diff_roles
         else
           puts 'no roles specified and no changes detected'
           exit 0
         end

  puts "-- Acceptance tests for #{role.join(', ')} --"
  paths = role.map do |klass|
    if klass.match(/^role/)
      spec_from_class(klass)
    else
      spec_from_class("role::#{klass}")
    end
  end.join(' ')
  Dir.chdir(role_path) do
    abort unless
      system "bash -c 'bundle exec rspec --format documentation #{paths}'"
  end
end
