require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before(:each) do
    @dummy_class = DummyClass.new
    @cached_env_debug = ''
    @original_stderr = $stderr
    @original_stdout = $stdout
    $stderr = File.open(File::NULL, 'w')
    $stdout = File.open(File::NULL, 'w')
    allow(@dummy_class)
      .to receive(:profile_path)
      .and_return("#{Dir.pwd}/fixtures/puppet-control/site/profile")
    FileUtils.rm_rf("#{Dir.pwd}/fixtures/puppet-control/site/profile/spec/"\
                    'fixtures/modules/profile')
  end
  after(:each) do
    $stderr = @original_stderr
    $stdout = @original_stdout
  end

  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      before(:each) do
        @cached_env_debug = ENV['debug']
        ENV['debug'] = 'true'
        allow(Dir)
          .to receive(:glob)
          .with("#{Dir.pwd}/fixtures/puppet-control/site/profile/../../modules"\
                '/*')
          .and_return(["#{Dir.pwd}/fixtures/puppet-control/site/profile/../../"\
                       'modules/concat',
                       "#{Dir.pwd}/fixtures/puppet-control/site/profile/../../"\
                       'modules/epel'])
      end

      after(:each) do
        ENV['debug'] = @cached_env_debug
      end

      context 'if a profile link already exists' do
        it 'should not try to symlink the profile path' do
          allow(File).to receive(:exist?)
            .with("#{Dir.pwd}/fixtures/puppet-control/site/profile/"\
                  'spec/fixtures/modules/profile')
            .and_return(true)
          expect(File).to_not receive(:symlink)
            .with("#{Dir.pwd}/fixtures/puppet-control/site/profile",
                  "#{Dir.pwd}/fixtures/puppet-control/site/profile/spec/"\
                  'fixtures/modules/profile')
          @dummy_class.profile_fixtures
        end
      end

      context 'if a profile link does not already exist' do
        it 'should symlink the profile path' do
          allow(File).to receive(:exist?)
            .with("#{Dir.pwd}/fixtures/puppet-control/site/profile/"\
                  'spec/fixtures/modules/profile')
            .and_return(false)
          expect(File).to receive(:symlink)
            .with("#{Dir.pwd}/fixtures/puppet-control/site/profile",
                  "#{Dir.pwd}/fixtures/puppet-control/site/profile/"\
                  'spec/fixtures/modules/profile')
          @dummy_class.profile_fixtures
        end
      end

      context 'when iterating through available modules' do
        before(:each) do
          allow(Dir).to receive(:glob)
            .with("#{Dir.pwd}/fixtures/puppet-control/site/profile/../"\
                  '../modules/*')
            .and_return([
                          "#{Dir.pwd}/fixtures/puppet-control/site/"\
                          'profile/../../modules/concat',
                          "#{Dir.pwd}/fixtures/puppet-control/site/"\
                          'profile/../../modules/epel'
                        ])
        end
        context 'if discovered file is not a directory' do
          before(:each) do
            allow(File).to receive(:directory?)
              .with("#{Dir.pwd}/fixtures/puppet-control/modules/concat")
              .and_return(false)
            allow(File).to receive(:directory?)
              .with("#{Dir.pwd}/fixtures/puppet-control/modules/epel")
          end
          it 'should not try to perform module operations on that file' do
            expect(File).to_not receive(:symlink?)
              .with("#{Dir.pwd}/fixtures/puppet-control/site/profile"\
                    '/../../modules/concat')
          end
        end

        context 'if discovered file is a directory' do
          before(:each) do
            allow(FileUtils)
              .to receive(:mkpath)
              .with("#{Dir.pwd}/fixtures/puppet-control/site/profile/spec/"\
                    'fixtures/modules/')
              .and_return(true)
            allow(File).to receive(:directory?)
              .with("#{Dir.pwd}/fixtures/puppet-control/site/profile"\
                    '/../../modules/concat')
              .and_return(true)
            allow(File).to receive(:directory?)
              .with("#{Dir.pwd}/fixtures/puppet-control/site/profile"\
                    '/../../modules/epel')
          end
          context 'if modules directories already are symlinks' do
            before(:each) do
              allow(File).to receive(:symlink?)
                .with("#{Dir.pwd}/fixtures/puppet-control/site/"\
                      'profile/../../modules/concat')
                .and_return(true)
              allow(File).to receive(:symlink?).at_least(2).times
            end
            it 'should not try to symlink the module path' do
              expect(File).to_not receive(:symlink)
                .with("#{Dir.pwd}/fixtures/puppet-control/site/"\
                      'profile/../../modules/concat',
                      "#{Dir.pwd}/spec/fixtures/modules/concat")
              @dummy_class.profile_fixtures
            end
          end

          context 'if modules directories do not already have symlinks' do
            before(:each) do
              allow(File).to receive(:symlink?)
                .with("#{Dir.pwd}/fixtures/puppet-control/site/"\
                      'profile/spec/fixtures/modules/concat')
                .and_return(false)
              allow(File).to receive(:directory?)
                .with("#{Dir.pwd}/fixtures/puppet-control/site/"\
                      'profile/../../modules/concat')
                .and_return(true)
              allow(File).to receive(:directory?)
                .with("#{Dir.pwd}/fixtures/puppet-control/site/profile/"\
                      '../../modules/epel')
            end
            it 'should symlink the module path' do
              expect(File).to receive(:symlink)
                .with("#{Dir.pwd}/fixtures/puppet-control/site/profile",
                      "#{Dir.pwd}/fixtures/puppet-control/site/"\
                      'profile/spec/fixtures/modules/profile')
              expect(File).to receive(:symlink)
                .with("#{Dir.pwd}/fixtures/puppet-control/site/"\
                      'profile/../../modules/concat',
                      "#{Dir.pwd}/fixtures/puppet-control/site/"\
                      'profile/spec/fixtures/modules/concat')
              @dummy_class.profile_fixtures
            end
          end

          it 'should create a modules directory inside fixtures' do
            expect(FileUtils)
              .to receive(:mkpath)
              .with("#{Dir.pwd}/fixtures/puppet-control/site/profile/spec/"\
                    'fixtures/modules/')
            @dummy_class.profile_fixtures
          end
        end
      end
    end
  end
end
