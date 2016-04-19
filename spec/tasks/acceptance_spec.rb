# spec/lib/tasks/acceptance_spec.rb

require 'spec_helper'

include ControlSpecHelper

describe 'acceptance', type: :rake do
  it do
    expect(subject).to be_a(Rake::Task)
    expect(subject).to eq(task)
  end
  context 'if ENV[\'role\'] or ENV[\'roles\'] is not empty' do
    before(:each) do
      previous_role_value = ENV['role']
      previous_roles_value = ENV['roles']
      ENV['role'] = 'foo'
      ENV['roles'] = 'bar,baz,zinga'
    end
    it 'should set role to singleton if ENV[\'role\'] is singleton' do
    end
    it 'should set role to singleton if ENV[\'roles\'] is singleton'
    it 'should set role to array if ENV[\'role\'] is array'
    it 'should set role to array if ENV[\'roles\'] is array'
  end
  context 'if ENV[\'role\'] and ENV[\'roles\'] are empty' do
    context 'if diff_roles is not empty' do
      it 'should set role to the output of diff_roles'
    end
    context 'if diff_roles is empty' do
      it 'should output debugging info' do
        #subject.invoke
      end
      it 'should exit cleanly'
    end
  end
  it 'should display output about acceptance tests' do
  end
  it 'should generate a list of paths'
  it 'should identify path for not-role class'
  it 'should identify path for role class'
  it 'should execute rspec against list of paths'
end
