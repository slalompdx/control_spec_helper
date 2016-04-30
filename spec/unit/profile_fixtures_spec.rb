require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      cached_env_debug = ''

      before(:each) do
        allow(@dummy_class).to receive(:profile_path).and_return('/')
        allow(File).to receive(:symlink)
          .with('/', '/tmp/spec/fixtures/modules/profile')
      end

      context 'if a profile link already exists' do
        it 'should not try to symlink the profile path' do
          allow(Dir).to receive(:glob).with('/tmp/../../modules/*')
            .and_return([])
          allow(File).to receive(:exists?)
            .with('/tmp/spec/fixtures/modules/profile').and_return(true)
          expect(File).to_not receive(:symlink)
            .with('/', '/tmp/spec/fixtures/modules/profile')
          allow(FileUtils).to receive(:mkpath)
            .with('/tmp/spec/fixtures/modules/')
          expect { @dummy_class.profile_fixtures }
        end
      end

      context 'if a profile link does not already exist' do
        it 'should symlink the profile path' do
          allow(Dir).to receive(:glob).with('/tmp/../../modules/*')
            .and_return([])
          allow(File).to receive(:exists?)
            .with('/tmp/spec/fixtures/modules/profile').and_return(false)
          allow(@dummy_class).to receive(:file_name).and_return('/tmp/foo.rb')
          expect(File).to receive(:symlink)
            .with('/', '/tmp/spec/fixtures/modules/profile')
          allow(FileUtils).to receive(:mkpath)
            .with('/tmp/spec/fixtures/modules/')
          @dummy_class.profile_fixtures
        end
      end

      context 'when iterating through available modules' do
        before(:each) do
          allow(Dir).to receive(:glob).with('/tmp/../../modules/*')
            .and_return(%w(foo bar))
          allow(File).to receive(:exists?)
            .with('/tmp/spec/fixtures/modules/profile').and_return(true)
        end

        context 'if discovered file is not a directory' do
          it 'should not try to perform module operations on that file' do
            allow(File).to receive(:directory?)
              .with('/tmp/spec/fixtures/modules').and_return(true)
            allow(File).to receive(:directory?).with('foo').and_return(false)
            allow(File).to receive(:directory?).with('bar').and_return(false)
            allow(@dummy_class).to receive(:file_name).and_return('/tmp/foo.rb')
            expect(File).to_not receive(:symlink)
              .with('/tmp/foo', '/tmp/spec/fixtures/modules/foo')
            expect(File).to_not receive(:symlink)
              .with('/tmp/bar', '/tmp/spec/fixtures/modules/bar')
            @dummy_class.profile_fixtures
          end
        end

        context 'if discovered file is a directory' do
          context 'if modules directories already are symlinks' do
            it 'should not try to symlink the module path' do
              allow(File).to receive(:directory?)
                .with('/tmp/spec/fixtures/modules').and_return(true)
              allow(File).to receive(:directory?).with('foo').and_return(true)
              allow(File).to receive(:directory?).with('bar').and_return(true)
              allow(@dummy_class).to receive(:file_name)
                .and_return('/tmp/foo.rb')
              allow(File).to receive(:symlink?)
                .with('/tmp/spec/fixtures/modules/foo').and_return(true)
              allow(File).to receive(:symlink?)
                .with('/tmp/spec/fixtures/modules/bar').and_return(true)
              @dummy_class.profile_fixtures
            end
          end

          context 'if modules directories do not already have symlinks' do
            it 'should symlink the module path' do
              allow(@dummy_class).to receive(:file_name)
                .and_return('/tmp/control_spec_helper.rb')
              allow(File).to receive(:directory?)
                .with('/tmp/spec/fixtures/modules').and_return(true)
              allow(File).to receive(:directory?)
                .with('foo').and_return(true)
              allow(File).to receive(:directory?)
                .with('bar').and_return(true)
              allow(File).to receive(:symlink?)
                .with('/tmp/spec/fixtures/modules/foo').and_return(false)
              allow(File).to receive(:symlink?)
                .with('/tmp/spec/fixtures/modules/bar').and_return(false)
              expect(File).to receive(:symlink)
                .with('/tmp/foo', '/tmp/spec/fixtures/modules/foo')
              expect(File).to receive(:symlink)
                .with('/tmp/bar', '/tmp/spec/fixtures/modules/bar')
              @dummy_class.profile_fixtures
            end
          end

          describe 'when debug environmental variable is set' do
            before(:each) do
              allow(@dummy_class).to receive(:profile_path).and_return('/')
              allow(@dummy_class).to receive(:file_name)
                .and_return('/tmp/foo.rb')
              allow(Dir).to receive(:glob).with('/tmp/../../modules/*')
                .and_return([])
              allow(Dir).to receive(:pwd).and_return('/foo')
              allow(File).to receive(:exists?)
                .with('/tmp/spec/fixtures/modules/profile').and_return(true)
              allow(FileUtils).to receive(:mkpath)
                .with('/tmp/spec/fixtures/modules/')
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
              allow(@dummy_class).to receive(:file_name)
                .and_return('/tmp/foo.rb')
              allow(Dir).to receive(:glob).with('/tmp/../../modules/*')
                .and_return([])
              allow(Dir).to receive(:pwd).and_return('/foo')
              allow(File).to receive(:exists?)
                .with('/tmp/spec/fixtures/modules/profile').and_return(true)
              allow(FileUtils).to receive(:mkpath)
                .with('/tmp/spec/fixtures/modules/')
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
            allow(@dummy_class).to receive(:file_name).and_return('/tmp/foo.rb')
            expect(FileUtils).to receive(:mkpath)
              .with('/tmp/spec/fixtures/modules/')
            @dummy_class.profile_fixtures
          end
        end
      end
    end
  end
end
