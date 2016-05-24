require 'rake'
require 'fakefs/spec_helpers'

shared_context 'control' do
  RSpec.configure do |config|
    config.before(:each) do
      FakeFS.activate!
      FileUtils.mkdir_p('/dev')
      FileUtils.mkdir_p('/tests')
      Git.clone('https://github.com/slalompdx/puppet-control.git',
                'puppet-control',
                path: '/proj/puppet-control',
                branch: 'fixture')
    end
    config.after(:each) do
      FakeFS.deactivate!
    end
  end
end
