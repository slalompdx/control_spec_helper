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

  it 'should print the puppet command' do
    cmd = "puppet apply manifests/site.pp \\\n      --modulepath $(echo `pwd`/modules:`pwd`/site) --hiera_config hiera.yaml"
    expect(@dummy_class.puppet_cmd).to eq(cmd)
  end
end
