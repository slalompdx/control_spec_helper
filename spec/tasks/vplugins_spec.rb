require 'spec_helper'
require 'net/ssh'

@config = nil
@original_dir = nil
@ssh = nil

describe :vplugins do
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

    let(:conf) { ssh_config }

    before(:each) do
      conf = ssh_config
      @connection = Net::SSH.start(
        conf['HostName'],
        conf['User'],
        port: conf['Port'],
        password: 'vagrant'
      )
      $stderr = File.open(File::NULL, 'w')
      $stdout = File.open(File::NULL, 'w')
    end

    after(:each) do
      $stderr = original_stderr
      $stdout = original_stdout
      @connection.close
    end

    it 'should install successfully' do
      response = ssh_exec!(@connection,
                           'cd /vagrant ; bundle exec rake vplugins')
      expect(response[2]).to eq(0)
    end

    it 'should install the vagrant-auto_network plugin' do
      response = ssh_exec!(@connection, 'unset RUBYLIB ; vagrant plugin list')
      puts response
      expect(response[0].split("\n")).to include(/vagrant-auto_network/)
    end

    it 'should install the vagrant-hosts plugin' do
      response = ssh_exec!(@connection, 'unset RUBYLIB ; vagrant plugin list')
      expect(response[0].split("\n")).to include(/vagrant-hosts/)
    end
  end
end
