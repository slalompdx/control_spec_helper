if ENV['serverspec']
  require 'serverspec'

  Specinfra.configuration.backend = :exec
else
  require 'beaker-rspec/spec_helper'
  require 'beaker-rspec/helpers/serverspec'

  UNSUPPORTED_PLATFORMS = %w(Suse windows AIX Solaris Debian).freeze

  RSpec.configure do |c|
    # Project root
    proj_root = File.expand_path(
      File.join(File.dirname(__FILE__), '..', '..', '..'))

    # Readable test descriptions
    c.formatter = :documentation

    # Configure all nodes in nodeset
    c.before :suite do
      # Install module and dependencies
      hosts.each do |host|
        role    = File.join(proj_root, 'dist', 'role')
        profile = File.join(proj_root, 'dist', 'profile')

        copy_module_to(host, source: role, module_name: 'role')
        copy_module_to(host, source: profile, module_name: 'profile')
        run_script_on host, File.join(proj_root, 'scripts', 'bootstrap.sh')
        shell 'mkdir -p /controlrepo'
        shell 'chown vagrant /controlrepo'
        install_package(host, 'zlib-devel')
        install_package(host, 'openssl-devel')
        `scp -i ~/.vagrant.d/insecure_private_key -o StrictHostKeyChecking=no \
          -r #{proj_root}  vagrant@#{host.connection.ip}:/`
        shell 'cd /controlrepo && gem install ./control_spec_helper-0.0.1.gem \
          && bundle install && rake r10k'
        shell 'mkdir -p /etc/facter/facts.d'
        role = ENV['role'].sub(/^role::/, '')
        shell "echo \"role=#{role}\" > /etc/facter/facts.d/role.txt"
      end
    end
  end

  shared_context 'beaker' do
    describe 'running puppet code' do
      it 'should apply cleanly' do
        pp = <<-EOS
          include "role::${::role}"
        EOS

        modulepath = '/controlrepo/dist:/controlrepo/modules'
        apply_manifest(pp, modulepath: modulepath, catch_failures: true)
      end
    end
  end
end
