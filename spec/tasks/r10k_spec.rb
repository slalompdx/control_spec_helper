require 'spec_helper'
require 'net/ssh'

describe :r10k do
  include_context 'rake'

  before(:all) do
    @original_dir = Dir.pwd
    Dir.chdir('fixtures/puppet-control')
  end

  after(:all) do
    Dir.chdir(@original_dir)
  end

  context 'when run on CentOS 7' do
    cached_env_debug = ''
    original_stderr = $stderr
    original_stdout = $stdout

    let(:conf) { ssh_config }

    before(:each) do
      $stderr = File.open(File::NULL, 'w')
      $stdout = File.open(File::NULL, 'w')
    end

    after(:each) do
      $stderr = original_stderr
      $stdout = original_stdout
    end

    it 'should run r10k and return successfully' do
      Net::SSH.start(
                      conf['HostName'],
                      conf['User'],
                      port: conf['Port'],
                      password: 'vagrant'
                    ) do |ssh|
                      ssh_exec!(ssh, 'cp /vagrant/fixtures/bashrc ~/.bashrc')
                    end
      r10k_return = Net::SSH.start(
                      conf['HostName'],
                      conf['User'],
                      port: conf['Port'],
                      password: 'vagrant'
                    ) do |ssh|
                      ssh_exec!(ssh, 'cd /vagrant ; bundle exec rake r10k')
                    end
      expect(r10k_return[2]).to eq(0)
      debug(r10k_return)
    end
  end
end
