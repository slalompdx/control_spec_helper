require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
    @cached_env_debug = ''
    @original_stderr = $stderr
    @original_stdout = $stdout
 #   $stderr = File.open(File::NULL, 'w')
 #   $stdout = File.open(File::NULL, 'w')
  end
  after do
    $stderr = @original_stderr
    $stdout = @original_stdout
  end

  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      before(:each) do
        allow(@dummy_class).to receive(:profile_path).and_return('/tmp/site/profiles')
        allow(Dir).to receive(:pwd).and_return('/tmp')
        allow(Dir).to receive(:chdir).and_return(true)
        @cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
      end
      after(:each) do
        ENV['debug'] = @cached_env_debug
      end

      context 'if a profile link already exists' do
        before(:each) do
          allow(Dir).to receive(:glob).with('/tmp/../../modules/*')
                    .and_return([])
          allow(File).to receive(:exist?)
                     .with('/tmp/spec/fixtures/modules/profile')
                     .and_return(true)
                     puts "========== HALLO"
        end

        it 'should not try to symlink the profile path' do
          expect(File).to_not receive(:symlink)
                      .with('/tmp/site/profiles',
                            '/tmp/spec/fixtures/modules/profile')
          @dummy_class.profile_fixtures
        end
      end

      context 'if a profile link does not already exist' do
        before(:each) do
          allow(Dir).to receive(:glob).with('/tmp/../../modules/*')
                    .and_return([])
          allow(File).to receive(:exist?)
                     .with('/tmp/spec/fixtures/modules/profile')
                     .and_return(false)
        end

        it 'should symlink the profile path' do
          allow(Dir).to receive(:pwd).and_return('/tmp')

          expect(File).to receive(:symlink)
#                      .with('/tmp/site/profiles',
#                            '/tmp/spec/fixtures/modules/profile')
          @dummy_class.profile_fixtures
        end
      end

      context 'when iterating through available modules' do
        context 'if discovered file is not a directory' do
          it 'should not try to perform module operations on that file'
        end

        context 'if discovered file is a directory' do
          context 'if modules directories already are symlinks' do
            it 'should not try to symlink the module path'
          end

          context 'if modules directories do not already have symlinks' do
            it 'should symlink the module path'
          end

          describe 'when debug environmental variable is set' do
            it 'should print its current profile_path directory'
            it 'should print its actual working directory'
          end

          context 'when debug environmental variable is not set' do
            it 'should not print its current profile_path directory'
            it 'should not print its actual working directory'
          end

          it 'should create a modules directory inside fixtures'
        end
      end
    end
  end
end
