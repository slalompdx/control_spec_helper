require 'spec_helper'

describe :unit do
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
      @connection = build_vagrant_connection(vagrant_ssh_config)
      ssh_exec!(@connection, 'cp /vagrant/fixtures/bashrc ~/.bashrc')
      $stderr = File.open(File::NULL, 'w')
      $stdout = File.open(File::NULL, 'w')
    end

    after(:each) do
      $stderr = original_stderr
      $stdout = original_stdout
    end

    repo = "#{File.dirname(__FILE__)}/../../fixtures/puppet-control"

    context 'when all tests pass' do
      before(:each) do
        Git.open(repo).checkout('unit_pass')
      end

      after(:each) do
        Git.open(repo).checkout('fixture')
      end

      it 'should run rspec and return successfully' do
        cmd = 'cd /vagrant ; bundle exec rake unit'
        _, _, exit_code, = ssh_exec!(@connection, cmd)
        expect(exit_code).to eq(0)
      end
    end

    context 'when at least one test fails' do
      before(:context) do
        Git.open(repo).checkout('unit_fail')
      end

      after(:context) do
        Git.open(repo).checkout('fixture')
      end

      it 'should run rspec and return an error code & message' do
        cmd = 'cd /vagrant ; bundle exec rake unit'
        msg, _, exit_code, = ssh_exec!(@connection, cmd)
        expect(exit_code).to_not eq(0)
        expect(msg).to match(/Failed examples:/)
      end
    end
  end
end

