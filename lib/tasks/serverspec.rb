# lib/tasks/serverspec.rb

desc 'Run acceptance tests locally from SUT'
task :serverspec do
  Dir.chdir(role_path) do
    role_spec = ENV['role'] || `facter role`.chomp.split('::').join('/')
    ENV['serverspec'] = 'true'
    system "rspec spec/acceptance/#{role_spec}_spec.rb"
  end
end
