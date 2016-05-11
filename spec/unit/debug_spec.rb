require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when debug environmental variable is set' do
    it 'should print properly-formatted debugging messages' do
      cached_env_debug = ENV['debug']
      ENV['debug'] = 'true'
      expect { debug('spec') }.to output("DEBUG: spec\n").to_stderr
      ENV['debug'] = cached_env_debug
    end
  end

  describe 'when debug environmental variable is not set' do
    it 'should suppress debugging messages' do
      cached_env_debug = ENV['debug']
      ENV.delete('debug')
      expect { debug('spec') }.to_not output('DEBUG: spec')
        .to_stderr
      ENV['debug'] = cached_env_debug
    end
  end
end
