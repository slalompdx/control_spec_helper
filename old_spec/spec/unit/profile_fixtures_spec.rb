require 'spec_helper'
require 'fakefs'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper', fakefs:true do
  include FakeFS::SpecHelpers

  before do
    @dummy_class = DummyClass.new
    @cached_env_debug = ''
    @original_stderr = $stderr
    @original_stdout = $stdout
    $stderr = File.new(File::NULL, 'w')
    $stdout = File.new(File::NULL, 'w')
  end
  after do
    $stderr = @original_stderr
    $stdout = @original_stdout
  end

  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      before(:each) do
        @cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
      end
      after(:each) do
        ENV['debug'] = @cached_env_debug
      end

      context 'if a profile link already exists' do
        it 'should not try to symlink the profile path' do
          expect(File).to_not receive(:symlink)
                      .with('/tmp/site/profiles',
                            '/tmp/spec/fixtures/modules/profile')
          @dummy_class.profile_fixtures
        end
      end

      context 'if a profile link does not already exist' do
        it 'should symlink the profile path' do
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
