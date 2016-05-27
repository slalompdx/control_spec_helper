require 'spec_helper'

describe :apply do
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

    context 'it should run puppet apply' do
      before(:each) do
        @puppet_return = ssh_exec!(@connection,
                                   'cd /vagrant ; bundle exec rake apply')
      end
      it 'should return successfully' do
        expect(@puppet_return[2]).to eq(0)
      end
      it 'should apply a catalog' do
        expect(@puppet_return[0]).to match(/Notice: Applied catalog/)
      end
      it 'should activate the ntp service' do
        @ntp_return = ssh_exec!(@connection,
                                'systemctl status ntpd')
        expect(@ntp_return[2]).to eq(0)
      end
      context 'the newly deployed ntp.conf' do
        before(:each) do
          @conf_content = ssh_exec!(@connection, 'cat /etc/ntp.conf')
        end
        it 'should contain the correct ntp servers' do
          expect(@conf_content[0]).to match(/server 0.pool.ntp.org/)
        end
        it 'should not contain additional ntp servers' do
          expect(@conf_content[0]).to_not match(/server 1.pool.ntp.org/)
        end
      end
    end
  end
end
