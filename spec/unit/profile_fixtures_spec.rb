require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when profile_fixtures is called' do
    describe 'when debug environmental variable is set' do
      context 'if a profile link already exists' do
        it 'should not try to symlink the profile path'
      end

      context 'if a profile link does not already exist' do
        it 'should symlink the profile path'
      end

      context 'when iterating through available modules' do
        context 'if discovered file is not a directory' do
          it 'should not try to perform module operations on that file'
        end

        context 'if discovered file is a directory' do
          context 'if modules directories already are symlinks' do
            it 'should not try to symlink the module path'
          end

          context 'if modules directories do not already have symlinks' do
            it 'should symlink the module path'
          end

          describe 'when debug environmental variable is set' do
            it 'should print its current profile_path directory'
            it 'should print its actual working directory'
          end

          context 'when debug environmental variable is not set' do
            it 'should not print its current profile_path directory'
            it 'should not print its actual working directory'
          end

          it 'should create a modules directory inside fixtures'
        end
      end
    end
  end
end
