require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when r10k is called' do
    cached_env_debug = ''
    original_stderr = $stderr
    original_stdout = $stdout

    before(:each) do
      allow(@dummy_class).to receive(:project_root).and_return('/')
      allow(@dummy_class).to receive(:`).with('r10k puppetfile install')
      # Redirect stderr and stdout
      $stderr = File.open(File::NULL, 'w')
      $stdout = File.open(File::NULL, 'w')
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
end
