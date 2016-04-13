require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  it 'should have a default basepath' do
    expect(@dummy_class.basepath).to eq('site')
  end

  it 'should allow you to set basepath' do
    @dummy_class.basepath = 'dist'
    expect(@dummy_class.basepath).to eq('dist')
  end

  it 'should have a default basebranch' do
    expect(@dummy_class.basebranch).to eq('master')
  end

  it 'should allow you to set basebranch' do
    @dummy_class.basebranch = 'production'
    expect(@dummy_class.basebranch).to eq('production')
  end

  describe 'when debug environmental variable is set' do
    it 'should print properly-formatted debugging messages' do
      cached_env_debug = ENV['debug']
      ENV['debug'] = 'true'
      expect { @dummy_class.debug('spec') }.to output("DEBUG: spec\n").to_stdout
      ENV['debug'] = cached_env_debug
    end
  end

  describe 'when debug environmental variable is not set' do
    it 'should suppress debugging messages' do
      cached_env_debug = ENV['debug']
      ENV['debug'] = ''
      expect { @dummy_class.debug('spec') }.to_not output('DEBUG: spec').to_stdout
      ENV['debug'] = cached_env_debug
    end
  end

  it 'should print the puppet command' do
    cmd = "puppet apply manifests/site.pp \\\n      --modulepath $(echo `pwd`/modules:`pwd`/site) --hiera_config hiera.yaml"
    expect(@dummy_class.puppet_cmd).to eq(cmd)
  end

  describe 'when root is set' do
    describe 'when project_root is called' do
      it 'should return a matching project_root' do
        @dummy_class.instance_variable_set(:@root, '/projroot')
        expect(@dummy_class.project_root).to eq('/projroot')
      end
    end
  end

  describe 'when root is not set' do
    describe 'when project_root is called' do
      git_string = 'git rev-parse --show-toplevel'
      it 'calls the appropriate git command' do
        expect(@dummy_class).to receive(:`).with(git_string)
          .and_return('foo')
        @dummy_class.project_root
      end

      describe 'result' do
        let(:test_root) { '/test_root' }

        before do
          allow(@dummy_class).to receive(:`).with(git_string)
            .and_return(test_root)
        end

        it 'should return a programmatically-determined project_root' do
          expect(@dummy_class.project_root).to eq('/test_root')
        end
      end
    end
  end

  it 'should return a role_path based on basepath' do
    @dummy_class.instance_variable_set(:@root, '/projroot')
    @dummy_class.basepath = 'dist'
    expect(@dummy_class.role_path).to eq('/projroot/dist/role')
  end

  it 'should return a profile_path based on basepath' do
    @dummy_class.instance_variable_set(:@root, '/projroot')
    @dummy_class.basepath = 'dist'
    expect(@dummy_class.profile_path).to eq('/projroot/dist/profile')
  end

  it 'should return a diff from a local basebranch'
  describe 'when diff_roles is called' do
    it 'should return a diff from base as a map'
  end
  describe 'when diff_profile is called' do
    it 'should return a diff from base as a map'
  end
  describe 'when passed a file path' do
    it 'should be able to extrapolate a puppet class name'
  end
  describe 'when passed a puppet class' do
    it 'should be able to identify roles that contain that class'
    it 'should be able to identify a spec file based on class name'
  end
  it 'should be able to identify all roles changed since last commit'
  describe 'when r10k is called' do
    it 'should call the appropriate r10k command'
    describe 'when debug environmental variable is set' do
      it 'should print its current project directory'
      it 'should print its actual working directory'
    end
  end
  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      it 'should print its current profile_path directory'
      it 'should print its actual working directory'
    end
    it 'should create a modules directory inside fixtures'
    describe 'when a profile directory exists inside fixtures' do
      it 'should not create a new symlink'
    end
    describe 'when a profile directory does not exist inside fixtures' do
      it 'should create a symlink to the profile directory'
    end
    describe 'for each file in the modules directory' do
      it 'should skip any file that is not a directory'
      it 'should symlink the module into the fixtures directory'
    end
  end
  describe 'when spec_clean is called' do
    describe 'when debug environmental variable is set' do
      it 'should print its current project directory'
      it 'should print its actual working directory'
    end
    it 'should abort if fixtures is empty'
    it 'should abort is fixtures is null'
    it 'should abort if modules is empty'
    it 'should abort if modules is null'
    it 'calls the appropriate command to remove fixtures'
    it 'calls the appropriate command to remove modules'
  end
end
