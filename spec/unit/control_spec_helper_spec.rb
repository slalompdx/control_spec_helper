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

  describe 'when diff_from_base is called' do
    git_command = 'git diff production --cached --diff-filter=ACMR --name-only'

    it 'should call the appropriate git command' do
      @dummy_class.basebranch = 'production'
      expect(@dummy_class).to receive(:`).with(git_command)
        .and_return("a\nb\nc")
      @dummy_class.diff_from_base
    end

    describe 'result' do
      before do
        @dummy_class.basebranch = 'production'
        allow(@dummy_class).to receive(:`).with(git_command)
          .and_return("a\nb\nc")
      end

      it 'should return an array' do
        expect(@dummy_class.diff_from_base).to eq(['a','b','c'])
      end
    end
  end

  describe 'when diff_roles is called' do
    it 'should return a diff from base as a map'
  end

  describe 'when diff_profile is called' do
    it 'should return a diff from base as a map'
  end

  describe 'when passed a file path' do
    describe 'if the path does not include manifests' do
      let(:path) { '/test_path/foobar.pp' }

      it 'should return nil' do
        expect(@dummy_class.class_from_path(path)).to eq(nil)
      end
    end

    describe 'if the path does not end in pp' do
      let(:path) { '/test_path/manifests/foobar' }
      it 'should return nil' do
        expect(@dummy_class.class_from_path(path)).to eq(nil)
      end
    end

    context 'when path is simple profile path' do
      let(:path) { '/test_path/site/profiles/manifests/klass.pp' }
      it 'should extrapolate a puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path)).to eq('profiles::klass')
      end
    end

    context 'when path is namespaced profile path' do
      let(:path) { '/test_path/site/profiles/manifests/klass/subklass.pp' }
      it 'should extrapolate a namespaced puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path))
          .to eq('profiles::klass::subklass')
      end
    end

    context 'when path is simple role path' do
      let(:path) { '/test_path/site/role/manifests/klass.pp' }
      it 'should extrapolate a puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path)).to eq('role::klass')
      end
    end

    context 'when path is namespaced role path' do
      let(:path) { '/test_path/site/role/manifests/klass/subklass.pp' }
      it 'should extrapolate a namespaced puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path))
          .to eq('role::klass::subklass')
      end
    end
  end

  describe 'when passed a puppet class' do
    let(:klass) { 'klass' }
    it 'should be able to identify roles that contain that class' do
      Dir.stub(:chdir).with('/test_path/site/role')
      allow(@dummy_class).to receive(:role_path)
        .and_return('/test_path/site/role')
      allow(@dummy_class).to receive(:project_root).and_return('/test_path')
      allow(@dummy_class).to receive(:`).with('git grep -l klass')
        .and_return("manifests/klass.pp\n" +
                    "manifests/klass/repo.pp\n" +
                    "manifests/stages.pp\n" +
                    "spec/classes/klass_spec.rb\n" +
                    "spec/classes/klass/repo_spec.rb\n" +
                    'spec/classes/stages_spec.rb')
      expect(@dummy_class.roles_that_include(klass)).to eq(['klass','klass::repo','stages'])
    end
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
