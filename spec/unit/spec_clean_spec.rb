require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
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
      begin
        expect { @dummy_class.spec_clean }
      rescue => e
        puts e
      end
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if fixtures is null' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      fixtures = nil
      begin
        expect { @dummy_class.spec_clean }
      rescue => e
        puts e
      end
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if modules is empty' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      modules = ''
      begin
        expect { @dummy_class.spec_clean }
      rescue => e
        puts e
      end
    end
    # rubocop:enable Lint/UselessAssignment

    # rubocop:disable Lint/UselessAssignment
    it 'should abort if modules is null' do
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      modules = nil
      begin
        expect { @dummy_class.spec_clean }
      rescue => e
        puts e
      end
    end
    # rubocop:enable Lint/UselessAssignment

    it 'calls the appropriate command to remove fixtures' do
      allow(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      expect(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      @dummy_class.spec_clean
    end

    it 'calls the appropriate command to remove modules' do
      expect(@dummy_class).to receive(:`).with('rm -rf /modules/*')
      allow(@dummy_class).to receive(:`)
        .with('rm -rf /tmp/spec/fixtures/modules/*')
      @dummy_class.spec_clean
    end
  end
end
