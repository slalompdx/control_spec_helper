require 'spec_helper'

describe :puppet_cmd do
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
      @prep_return = ssh_exec!(@connection,
                               'cd /vagrant ;'\
                               'bundle exec rake puppet_cmd')
    end

    after(:each) do
      $stderr = original_stderr
      $stdout = original_stdout
    end

    it 'should return success' do
      expect(@prep_return[2]).to eq(0)
    end

    it 'should return the correct puppet command' do
      expect(@prep_return[0])
        .to match(
          "sudo puppet apply manifests/site.pp \\\n      --modulepath "\
          "$(echo `pwd`/modules:`pwd`/site) --hiera_config hiera.yaml\n"
        )
    end
  end
end
