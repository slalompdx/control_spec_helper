require 'spec_helper'

describe :vplugins do
  original_stderr = $stderr
  original_stdout = $stdout
  include_context 'rake'

  before(:each) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, 'w')
    $stdout = File.open(File::NULL, 'w')
  end

  after(:each) do
    $stderr = original_stderr
    $stdout = original_stdout
  end

  it 'should install the vagrant-auto_network plugin' do
    subject.execute
    get_plugins.include? 'vagrant-auto_network'
  end

  it 'should install the vagrant-hosts plugin' do
    subject.execute
    get_plugins.include? 'vagrant-hosts'
  end
end

def get_plugins
  `unset RUBYLIB ; vagrant plugin list`.split("\n")
end
