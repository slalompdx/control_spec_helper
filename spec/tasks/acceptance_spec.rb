# spec/lib/tasks/acceptance_spec.rb

require 'spec_helper'

describe 'acceptance' do
  include_context 'rake'

  it do
#    expect { Rake::Task['spec_clean'] }.to_receive(:invoke)
    subject.invoke
  end
end
