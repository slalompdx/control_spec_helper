require 'spec_helper'

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
    # rubocop:disable Lint/UselessAssignment
    cached_env_debug = ''
    # rubocop:enable Lint/UselessAssignment
    original_stderr = $stderr
    original_stdout = $stdout

    before(:each) do
      conf = ssh_config
      @connection = Net::SSH.start(
        conf['HostName'],
        conf['User'],
        port: conf['Port'],
        password: 'vagrant'
      )
      ssh_exec!(@connection, 'cp /vagrant/fixtures/bashrc ~/.bashrc')
      $stderr = File.open(File::NULL, 'w')
      $stdout = File.open(File::NULL, 'w')
    end

    after(:each) do
      $stderr = original_stderr
      $stdout = original_stdout
    end

    context 'when Puppetfile is valid' do
      it 'should run r10k and return successfully' do
        r10k_return = ssh_exec!(@connection,
                                'cd /vagrant ; bundle exec rake r10k')
        expect(r10k_return[2]).to eq(0)
        debug(r10k_return)
      end
    end
    context 'when Puppetfile is invalid' do
      before(:all) do
        Git.open("#{File.dirname(__FILE__)}/../../fixtures/puppet-control")
           .checkout('bad_puppetfile')
      end
      after(:all) do
        Git.open("#{File.dirname(__FILE__)}/../../fixtures/puppet-control")
           .checkout('fixture')
      end
      it 'should run r10k and return an error code' do
        r10k_return = ssh_exec!(@connection,
                                'cd /vagrant ; bundle exec rake r10k')
        expect(r10k_return[2]).to_not eq(0)
      end
      it 'should run r10k and return an error message' do
        r10k_return = ssh_exec!(@connection,
                                'cd /vagrant ; bundle exec rake r10k')
        expect(r10k_return[1]).to match(/ERROR/)
      end
    end
  end
end
