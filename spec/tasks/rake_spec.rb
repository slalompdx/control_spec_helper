# spec/lib/tasks/notification_rake_spec.rb
require 'spec_helper'

describe 'git' do
  include_context 'rake'

  it do
    subject.invoke
  end
end
