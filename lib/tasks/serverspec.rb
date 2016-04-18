# lib/tasks/serverspec.rb

desc 'Run acceptance tests locally from SUT'
task :serverspec do
  Dir.chdir(role_path) do
    if ENV['role']
      role_spec = ENV['role']
    else
      role_spec = `facter role`.chomp.split('::').join('/')
    end
    ENV['serverspec'] = 'true'
    system "rspec spec/acceptance/#{role_spec}_spec.rb"
  end
end
