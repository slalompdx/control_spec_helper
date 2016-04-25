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
      expect { @dummy_class.debug('spec') }.to output("DEBUG: spec\n").to_stderr
      ENV['debug'] = cached_env_debug
    end
  end

  describe 'when debug environmental variable is not set' do
    it 'should suppress debugging messages' do
      cached_env_debug = ENV['debug']
      ENV.delete('debug')
      expect { @dummy_class.debug('spec') }.to_not output('DEBUG: spec')
        .to_stderr
      ENV['debug'] = cached_env_debug
    end
  end

  it 'should print the puppet command' do
    cmd = "puppet apply manifests/site.pp \\\n      --modulepath " \
          '$(echo `pwd`/modules:`pwd`/site) --hiera_config hiera.yaml'
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
        expect(@dummy_class.diff_from_base).to eq(%w(a b c))
      end
    end
  end

  describe 'when diff_roles is called' do
    it 'should return a diff from base as an array' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      'a',
                      '/tmp/foo/site/role/manifests/foo.pp',
                      '/tmp/foo/site/role/manifests/bar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_roles)
        .and_return(['role::foo', 'role::bar'])
      @dummy_class.diff_roles
    end

    it 'should ignore classes in base that are not roles' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      '/tmp/foo/site/profile/manifests/foo.pp',
                      '/tmp/foo/site/role/manifests/bar.pp',
                      '/tmp/foo/modules/baz/manifests/baz.pp',
                      '/tmp/foo/site/role/manifests/fubar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_roles)
        .and_return(['role::bar', 'role::fubar'])
      @dummy_class.diff_roles
    end
  end

  describe 'when diff_profile is called' do
    it 'should return a diff from base as a map' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      'a',
                      '/tmp/foo/site/profile/manifests/foo.pp',
                      '/tmp/foo/site/profile/manifests/bar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_profile)
        .and_return(['profile::foo', 'profile::bar'])
      @dummy_class.diff_profile
    end

    it 'should ignore classes in base that are not profiles' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      '/tmp/foo/site/profile/manifests/foo.pp',
                      '/tmp/foo/site/role/manifests/bar.pp',
                      '/tmp/foo/modules/baz/manifests/baz.pp',
                      '/tmp/foo/site/profile/manifests/fubar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_roles)
        .and_return(['profile::foo', 'profile::fubar'])
      @dummy_class.diff_roles
    end
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
      allow(@dummy_class).to receive(:role_path).and_return('/')
      allow(@dummy_class).to receive(:project_root).and_return('/test_path')
      allow(@dummy_class).to receive(:`).with('git grep -l klass')
        .and_return("manifests/klass.pp\n" \
                    "manifests/klass/repo.pp\n" \
                    "manifests/stages.pp\n" \
                    "spec/classes/klass_spec.rb\n" \
                    "spec/classes/klass/repo_spec.rb\n" \
                    'spec/classes/stages_spec.rb')
      expect(@dummy_class.roles_that_include('klass'))
        .to eq(["::klass", "::klass::repo", "::stages"])
    end

    describe 'when asked to identify a spec file based on class name' do
      let(:klass) { 'profile::klass' }
      let(:role_klass) { 'role::klass' }
      it 'should fail if class is neither role nor profile' do
        expect { @dummy_class.spec_from_class('klass') }
          .to raise_error ArgumentError
      end

      context 'when passed a profile class' do
        it 'should be able to identify a spec file based on class name' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(klass))
            .to eq('/test_root/control_spec_helper/profile/spec/klass_spec.rb')
        end

        it 'should place a profile spec in the correct path' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(klass))
            .to eq('/test_root/control_spec_helper/profile/spec/klass_spec.rb')
        end

        it 'should place a role spec in the correct path' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(role_klass))
            .to eq('/test_root/control_spec_helper/role/spec/acceptance/klass_spec.rb')
        end
      end
    end
  end

  describe 'when r10k is called' do
    cached_env_debug = ''
    original_stderr = $stderr
    original_stdout = $stdout

    before(:each) do
      allow(@dummy_class).to receive(:project_root).and_return('/')
      allow(@dummy_class).to receive(:`).with('r10k puppetfile install')
      # Redirect stderr and stdout
      $stderr = File.new(File.join('/', 'dev', 'null'), 'w')
      $stdout = File.new(File.join('/', 'dev', 'null'), 'w')
    end

    after(:each) do
      $stderr = original_stderr
      $stdout = original_stdout
    end

    it 'should call the appropriate r10k command' do
      allow(@dummy_class).to receive(:project_root).and_return('/')
      expect(@dummy_class).to receive(:`).with('r10k puppetfile install')
      @dummy_class.r10k
    end

    describe 'when debug environmental variable is set' do
      cached_env_debug = ''
      before(:each) do
        allow(@dummy_class).to receive(:project_root).and_return('/')
        allow(@dummy_class).to receive(:`).with('r10k puppetfile install')
        cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
      end
      after(:each) do
        ENV['debug'] = cached_env_debug
      end

      it 'should print its current project directory' do
        expect { @dummy_class.r10k }.to output(%r{cd to /}).to_stderr
      end

      it 'should print its actual working directory' do
        allow(Dir).to receive(:pwd).and_return('/tmp')
        expect { @dummy_class.r10k }.to output(%r{cd to /tmp}).to_stderr
      end
    end
  end

  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      cached_env_debug = ''

      before(:each) do
        allow(@dummy_class).to receive(:profile_path).and_return('/')
        allow(File).to receive(:symlink)
          .with('/', './spec/fixtures/modules/profile')
      end

      context 'if a profile link already exists' do
        it 'should not try to symlink the profile path' do
          allow(Dir).to receive(:glob).with('../../modules/*').and_return([])
          allow(File).to receive(:exists?)
            .with('./spec/fixtures/modules/profile').and_return(true)
          expect(File).to_not receive(:symlink)
            .with('/', './spec/fixtures/modules/profile')
          allow(FileUtils).to receive(:mkpath).with('./spec/fixtures/modules/')
          expect { @dummy_class.profile_fixtures }
        end
      end

      context 'if a profile link does not already exist' do
        it 'should symlink the profile path' do
          allow(Dir).to receive(:glob).with('../../modules/*').and_return([])
          allow(File).to receive(:exists?)
            .with('./spec/fixtures/modules/profile').and_return(false)
          expect(File).to receive(:symlink)
            .with('/', './spec/fixtures/modules/profile')
          allow(FileUtils).to receive(:mkpath)
            .with('./spec/fixtures/modules/')
          @dummy_class.profile_fixtures
        end
      end

      context 'when iterating through available modules' do
        before(:each) do
          allow(Dir).to receive(:glob).with('../../modules/*')
            .and_return(%w(foo bar))
          allow(File).to receive(:exists?)
            .with('./spec/fixtures/modules/profile').and_return(true)
        end

        context 'if discovered file is not a directory' do
          it 'should not try to perform module operations on that file' do
            allow(File).to receive(:directory?).with('./spec/fixtures/modules')
              .and_return(true)
            allow(File).to receive(:directory?).with('foo').and_return(false)
            allow(File).to receive(:directory?).with('bar').and_return(false)
            allow(File).to receive(:dirname).with(__FILE__).and_return('/tmp')
            expect(File).to_not receive(:symlink)
              .with('/tmp/foo', './spec/fixtures/modules/foo')
            expect(File).to_not receive(:symlink)
              .with('/tmp/bar', './spec/fixtures/modules/bar')
            @dummy_class.profile_fixtures
          end
        end

        context 'if discovered file is a directory' do
          context 'if modules directories already are symlinks' do
            it 'should not try to symlink the module path' do
              allow(File).to receive(:directory?)
                .with('./spec/fixtures/modules').and_return(true)
              allow(File).to receive(:directory?).with('foo').and_return(true)
              allow(File).to receive(:directory?).with('bar').and_return(true)
              allow(File).to receive(:dirname).and_return('/tmp')
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/foo').and_return(true)
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/bar').and_return(true)
              @dummy_class.profile_fixtures
            end
          end

          context 'if modules directories do not already have symlinks' do
            it 'should symlink the module path' do
              allow(@dummy_class).to receive(:expanded_file_name)
                .and_return('/tmp/control_spec_helper.rb')
              allow(File).to receive(:directory?)
                .with('./spec/fixtures/modules').and_return(true)
              allow(File).to receive(:directory?)
                .with('foo').and_return(true)
              allow(File).to receive(:directory?)
                .with('bar').and_return(true)
              allow(File).to receive(:dirname)
                .with(@dummy_class.file_name).and_return('/tmp')
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/foo').and_return(false)
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/bar').and_return(false)
              expect(File).to receive(:symlink)
                .with('/tmp/foo', './spec/fixtures/modules/foo')
              expect(File).to receive(:symlink)
                .with('/tmp/bar', './spec/fixtures/modules/bar')
              @dummy_class.profile_fixtures
            end
          end

          describe 'when debug environmental variable is set' do
            before(:each) do
              allow(@dummy_class).to receive(:profile_path).and_return('/')
              allow(Dir).to receive(:glob).with('../../modules/*')
                .and_return([])
              allow(Dir).to receive(:pwd).and_return('/foo')
              allow(File).to receive(:exists?)
                .with('./spec/fixtures/modules/profile').and_return(true)
              allow(FileUtils).to receive(:mkpath)
                .with('./spec/fixtures/modules/')
              cached_env_debug = ENV['debug']
              ENV['debug'] = 'true'
            end

            after(:each) do
              ENV['debug'] = cached_env_debug
            end

            it 'should print its current profile_path directory' do
              expect { @dummy_class.profile_fixtures }
                .to output(%r{DEBUG: cd to /}).to_stderr
            end

            it 'should print its actual working directory' do
              expect { @dummy_class.profile_fixtures }
                .to output(%r{DEBUG: cd to /foo}).to_stderr
            end
          end

          context 'when debug environmental variable is not set' do
            before(:each) do
              allow(@dummy_class).to receive(:profile_path).and_return('/')
              allow(Dir).to receive(:glob).with('../../modules/*')
                .and_return([])
              allow(Dir).to receive(:pwd).and_return('/foo')
              allow(File).to receive(:exists?)
                .with('./spec/fixtures/modules/profile').and_return(true)
              allow(FileUtils).to receive(:mkpath)
                .with('./spec/fixtures/modules/')
            end

            it 'should not print its current profile_path directory' do
              cached_env_debug = ENV['debug']
              ENV.delete('debug')
              expect { @dummy_class.profile_fixtures }
                .to_not output(%r{DEBUG: cd to /}).to_stderr
              ENV['debug'] = cached_env_debug
            end

            it 'should not print its actual working directory' do
              cached_env_debug = ENV['debug']
              ENV.delete('debug')
              expect { @dummy_class.profile_fixtures }
                .to_not output(%r{DEBUG: cd to /foo}).to_stderr
              ENV['debug'] = cached_env_debug
            end
          end

          it 'should create a modules directory inside fixtures' do
            expect(FileUtils).to receive(:mkpath)
              .with('./spec/fixtures/modules/')
            @dummy_class.profile_fixtures
          end
        end
      end
    end
  end

  describe 'when spec_clean is called' do
    before(:each) do
      allow(@dummy_class).to receive(:project_root).and_return('/')
      allow(@dummy_class).to receive(:profile_path).and_return('/tmp')
      allow(Dir).to receive(:pwd).and_return('/foo')
    end

    describe 'when debug environmental variable is set' do
      it 'should print its current project directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
        expect { @dummy_class.spec_clean }.to output(%r{DEBUG: cd to /})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end

      it 'should print its actual working directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
        expect { @dummy_class.spec_clean }.to output(%r{DEBUG: cd to /foo})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end
    end

    describe 'when debug environmental variable is not set' do
      it 'should not print its current project directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV.delete('debug')
        expect { @dummy_class.spec_clean }.to_not output(%r{DEBUG: cd to /})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end

      it 'should not print its actual working directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV.delete('debug')
        expect { @dummy_class.spec_clean }.to_not output(%r{DEBUG: cd to /})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end
    end

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if fixtures is empty' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      fixtures = ''
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if fixtures is null' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      fixtures = nil
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if modules is empty' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      modules = ''
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if modules is null' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      modules = nil
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    it 'calls the appropriate command to remove fixtures' do
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      expect(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      @dummy_class.clean_spec
    end

    it 'calls the appropriate command to remove modules' do
      expect(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      @dummy_class.clean_spec
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

  context 'should return a diff from a local basebranch' do
    it 'should return an array' do
      expect(@dummy_class.diff_from_base).to eq(['a','b','c'])
    end
  end

  describe 'when diff_roles is called' do
    it 'should return a diff from base as a map' do
      allow(@dummy_class).to receive(:diff_from_base).and_return(['/tmp/foo/site/profile/manifests/foo.pp','/tmp/foo/site/role/manifests/bar.pp','/tmp/foo/modules/baz/manifests/baz.pp','/tmp/foo/site/role/manifests/fubar.pp'])
      expect(@dummy_class).to receive(:diff_roles).and_return(['role::bar','role::fubar'])
      @dummy_class.diff_roles
    end
  end

  describe 'when diff_profile is called' do
    it 'should return a diff from base as a map' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      'a',
                      '/tmp/foo/site/profile/manifests/foo.pp',
                      '/tmp/foo/site/profile/manifests/bar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_profile)
        .and_return(['profile::foo', 'profile::bar'])
      @dummy_class.diff_profile
    end

    it 'should ignore classes in base that are not profiles' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      '/tmp/foo/site/profile/manifests/foo.pp',
                      '/tmp/foo/site/role/manifests/bar.pp',
                      '/tmp/foo/modules/baz/manifests/baz.pp',
                      '/tmp/foo/site/profile/manifests/fubar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_roles)
        .and_return(['profile::foo', 'profile::fubar'])
      @dummy_class.diff_roles
    end
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
      allow(@dummy_class).to receive(:role_path).and_return('/')
      allow(@dummy_class).to receive(:project_root).and_return('/test_path')
      allow(@dummy_class).to receive(:`).with('git grep -l klass')
        .and_return("manifests/klass.pp\n" \
                    "manifests/klass/repo.pp\n" \
                    "manifests/stages.pp\n" \
                    "spec/classes/klass_spec.rb\n" \
                    "spec/classes/klass/repo_spec.rb\n" \
                    'spec/classes/stages_spec.rb')
      expect { @dummy_class.roles_that_include('klass') }
        .to output("::klass\n::klass::repo\n::stages\n").to_stdout
    end

    describe 'when asked to identify a spec file based on class name' do
      let(:klass) { 'profile::klass' }
      let(:role_klass) { 'role::klass' }
      it 'should fail if class is neither role nor profile' do
        expect { @dummy_class.spec_from_class('klass') }
          .to raise_error ArgumentError
      end

      context 'when passed a profile class' do
        it 'should be able to identify a spec file based on class name' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(klass))
            .to eq('/test_root/control_spec_helper/profile/spec/klass_spec.rb')
        end

        it 'should place a profile spec in the correct path' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(klass))
            .to eq('/test_root/control_spec_helper/profile/spec/klass_spec.rb')
        end

        it 'should place a role spec in the correct path' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(role_klass))
            .to eq('/test_root/control_spec_helper/role/spec/acceptance/klass_spec.rb')
        end
      end
    end
  end

  describe 'when r10k is called' do
    it 'should call the appropriate r10k command' do
      allow(@dummy_class).to receive(:project_root).and_return('/')
      expect(@dummy_class).to receive(:`).with('r10k puppetfile install')
      expect { @dummy_class.r10k }.to output(/Installing modules with r10k/).to_stdout
    end

    describe 'when debug environmental variable is set' do
      cached_env_debug = ''
      original_stderr = $stderr
      original_stdout = $stdout
      before(:each) do
        allow(@dummy_class).to receive(:project_root).and_return('/')
        allow(@dummy_class).to receive(:`).with('r10k puppetfile install')
        # Redirect stderr and stdout
        $stderr = File.new(File.join('/', 'dev', 'null'), 'w')
        $stdout = File.new(File.join('/', 'dev', 'null'), 'w')
      end
      after(:each) do
        $stderr = original_stderr
        $stdout = original_stdout
      end

      it 'should print its current project directory' do
        cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
        expect { @dummy_class.r10k }.to output(/Installing modules with r10k/).to_stdout
        expect { @dummy_class.r10k }.to output(%r{cd to /}).to_stderr
        ENV['debug'] = cached_env_debug
      end

      it 'should print its actual working directory' do
        cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
        allow(Dir).to receive(:pwd).and_return('/tmp')
        expect { @dummy_class.r10k }.to output(/Installing modules with r10k/).to_stdout
        expect { @dummy_class.r10k }.to output(%r{cd to /tmp}).to_stderr
        ENV['debug'] = cached_env_debug
      end
    end
  end

  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      cached_env_debug = ''

      before(:each) do
        allow(@dummy_class).to receive(:profile_path).and_return('/')
        allow(File).to receive(:symlink)
          .with('/', './spec/fixtures/modules/profile')
      end

      context 'if a profile link already exists' do
        it 'should not try to symlink the profile path' do
          allow(Dir).to receive(:glob).with('../../modules/*').and_return([])
          allow(File).to receive(:exists?)
            .with('./spec/fixtures/modules/profile').and_return(true)
          expect(File).to_not receive(:symlink)
            .with('/', './spec/fixtures/modules/profile')
          allow(FileUtils).to receive(:mkpath).with('./spec/fixtures/modules/')
          expect { @dummy_class.profile_fixtures }
        end
      end

      context 'if a profile link does not already exist' do
        it 'should symlink the profile path' do
          allow(Dir).to receive(:glob).with('../../modules/*').and_return([])
          allow(File).to receive(:exists?)
            .with('./spec/fixtures/modules/profile').and_return(false)
          expect(File).to receive(:symlink)
            .with('/', './spec/fixtures/modules/profile')
          allow(FileUtils).to receive(:mkpath)
            .with('./spec/fixtures/modules/')
          @dummy_class.profile_fixtures
        end
      end

      context 'when iterating through available modules' do
        before(:each) do
          allow(Dir).to receive(:glob).with('../../modules/*')
            .and_return(%w(foo bar))
          allow(File).to receive(:exists?)
            .with('./spec/fixtures/modules/profile').and_return(true)
        end

        context 'if discovered file is not a directory' do
          it 'should not try to perform module operations on that file' do
            allow(File).to receive(:directory?).with('./spec/fixtures/modules')
              .and_return(true)
            allow(File).to receive(:directory?).with('foo').and_return(false)
            allow(File).to receive(:directory?).with('bar').and_return(false)
            allow(File).to receive(:dirname).with(__FILE__).and_return('/tmp')
            expect(File).to_not receive(:symlink)
              .with('/tmp/foo', './spec/fixtures/modules/foo')
            expect(File).to_not receive(:symlink)
              .with('/tmp/bar', './spec/fixtures/modules/bar')
            @dummy_class.profile_fixtures
          end
        end

        context 'if discovered file is a directory' do
          context 'if modules directories already are symlinks' do
            it 'should not try to symlink the module path' do
              allow(File).to receive(:directory?)
                .with('./spec/fixtures/modules').and_return(true)
              allow(File).to receive(:directory?).with('foo').and_return(true)
              allow(File).to receive(:directory?).with('bar').and_return(true)
              allow(File).to receive(:dirname).and_return('/tmp')
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/foo').and_return(true)
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/bar').and_return(true)
              @dummy_class.profile_fixtures
            end
          end

          context 'if modules directories do not already have symlinks' do
            it 'should symlink the module path' do
              allow(@dummy_class).to receive(:expanded_file_name)
                .and_return('/tmp/control_spec_helper.rb')
              allow(File).to receive(:directory?)
                .with('./spec/fixtures/modules').and_return(true)
              allow(File).to receive(:directory?)
                .with('foo').and_return(true)
              allow(File).to receive(:directory?)
                .with('bar').and_return(true)
              allow(File).to receive(:dirname)
                .with(@dummy_class.expanded_file_name).and_return('/tmp')
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/foo').and_return(false)
              allow(File).to receive(:symlink?)
                .with('./spec/fixtures/modules/bar').and_return(false)
              expect(File).to receive(:symlink)
                .with('/tmp/foo', './spec/fixtures/modules/foo')
              expect(File).to receive(:symlink)
                .with('/tmp/bar', './spec/fixtures/modules/bar')
              @dummy_class.profile_fixtures
            end
          end

          describe 'when debug environmental variable is set' do
            before(:each) do
              allow(@dummy_class).to receive(:profile_path).and_return('/')
              allow(Dir).to receive(:glob).with('../../modules/*')
                .and_return([])
              allow(Dir).to receive(:pwd).and_return('/foo')
              allow(File).to receive(:exists?)
                .with('./spec/fixtures/modules/profile').and_return(true)
              allow(FileUtils).to receive(:mkpath)
                .with('./spec/fixtures/modules/')
              cached_env_debug = ENV['debug']
              ENV['debug'] = 'true'
            end

            after(:each) do
              ENV['debug'] = cached_env_debug
            end

            it 'should print its current profile_path directory' do
              expect { @dummy_class.profile_fixtures }
                .to output(%r{DEBUG: cd to /}).to_stderr
            end

            it 'should print its actual working directory' do
              expect { @dummy_class.profile_fixtures }
                .to output(%r{DEBUG: cd to /foo}).to_stderr
            end
          end

          context 'when debug environmental variable is not set' do
            before(:each) do
              allow(@dummy_class).to receive(:profile_path).and_return('/')
              allow(Dir).to receive(:glob).with('../../modules/*')
                .and_return([])
              allow(Dir).to receive(:pwd).and_return('/foo')
              allow(File).to receive(:exists?)
                .with('./spec/fixtures/modules/profile').and_return(true)
              allow(FileUtils).to receive(:mkpath)
                .with('./spec/fixtures/modules/')
            end

            it 'should not print its current profile_path directory' do
              cached_env_debug = ENV['debug']
              ENV.delete('debug')
              expect { @dummy_class.profile_fixtures }
                .to_not output(%r{DEBUG: cd to /}).to_stderr
              ENV['debug'] = cached_env_debug
            end

            it 'should not print its actual working directory' do
              cached_env_debug = ENV['debug']
              ENV.delete('debug')
              expect { @dummy_class.profile_fixtures }
                .to_not output(%r{DEBUG: cd to /foo}).to_stderr
              ENV['debug'] = cached_env_debug
            end
          end

          it 'should create a modules directory inside fixtures' do
            expect(FileUtils).to receive(:mkpath)
              .with('./spec/fixtures/modules/')
            @dummy_class.profile_fixtures
          end
        end
      end
    end
  end

  describe 'when spec_clean is called' do
    before(:each) do
      allow(@dummy_class).to receive(:project_root).and_return('/')
      allow(@dummy_class).to receive(:profile_path).and_return('/tmp')
      allow(Dir).to receive(:pwd).and_return('/foo')
    end

    describe 'when debug environmental variable is set' do
      it 'should print its current project directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
        expect { @dummy_class.spec_clean }.to output(%r{DEBUG: cd to /})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end

      it 'should print its actual working directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
        expect { @dummy_class.spec_clean }.to output(%r{DEBUG: cd to /foo})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end
    end

    describe 'when debug environmental variable is not set' do
      it 'should not print its current project directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV.delete('debug')
        expect { @dummy_class.spec_clean }.to_not output(%r{DEBUG: cd to /})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end

      it 'should not print its actual working directory' do
        allow(@dummy_class).to receive(:`)
          .with('rm -rf /tmp/spec/fixtures/modules/*')
        allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
        cached_env_debug = ENV['debug']
        ENV.delete('debug')
        expect { @dummy_class.spec_clean }.to_not output(%r{DEBUG: cd to /})
          .to_stderr
        ENV['debug'] = cached_env_debug
      end
    end

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if fixtures is empty' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      fixtures = ''
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if fixtures is null' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      fixtures = nil
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if modules is empty' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      modules = ''
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if modules is null' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      modules = nil
      expect { @dummy_class.spec_clean }.to abort
    end
    # rubocop:enable Lint/UselessAssignment

    it 'calls the appropriate command to remove fixtures' do
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      expect(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      @dummy_class.clean_spec
    end

    it 'calls the appropriate command to remove modules' do
      expect(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      @dummy_class.clean_spec
    end
  end
end
