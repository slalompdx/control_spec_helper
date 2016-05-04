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
    let(:conf) { ssh_config }

    it 'should install successfully' do
      expect(Net::SSH.start(
        conf['HostName'],
        conf['User'],
        port: conf['Port'],
        password: 'vagrant'
      ) { |ssh|
        exec_output = ssh_exec!(ssh, 'cd /vagrant && unset RUBYLIB ; bundle exec rake vplugins', true)
      }[2]).to eq(0)
    end
    it 'should install the vagrant-auto_network plugin' do
      expect(Net::SSH.start(
        conf['HostName'],
        conf['User'],
        port: conf['Port'],
        password: 'vagrant'
      ) { |ssh|
        exec_output = ssh_exec!(ssh, 'unset RUBYLIB ; vagrant plugin list', true)
      }[0].split("\n")).to include(/vagrant-auto_network/)
    end
    it 'should install the vagrant-hosts plugin' do
      expect(Net::SSH.start(
        conf['HostName'],
        conf['User'],
        port: conf['Port'],
        password: 'vagrant'
      ) { |ssh|
        exec_output = ssh_exec!(ssh, 'unset RUBYLIB ; vagrant plugin list', true)
      }[0].split("\n")).to include(/vagrant-hosts/)
    end
  end
end

#  original_stderr = $stderr
#  original_stdout = $stdout
#  include_context 'rake'
#
#  before(:each) do
#    # Redirect stderr and stdout
#    $stderr = File.open(File::NULL, 'w')
#    $stdout = File.open(File::NULL, 'w')
#  end
#
#  after(:each) do
#    $stderr = original_stderr
#    $stdout = original_stdout
#  end
#
#  it 'should install the vagrant-auto_network plugin' do
#    subject.execute
#    get_plugins.include? 'vagrant-auto_network'
#  end
#
#  it 'should install the vagrant-hosts plugin' do
#    subject.execute
#    get_plugins.include? 'vagrant-hosts'
#  end
#end
#
#def get_plugins
#  `unset RUBYLIB ; vagrant plugin list`.split("\n")
#end
