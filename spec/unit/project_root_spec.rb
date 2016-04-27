require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when root is set' do
    describe 'when project_root is called' do
      it 'should return a matching project_root' do
        @dummy_class.instance_variable_set(:@root, '/projroot')
        expect(@dummy_class.project_root).to eq('/projroot')
      end
    end
  end

  describe 'when root is not set' do
    describe 'when project_root is called' do
      git_string = 'git rev-parse --show-toplevel'

      it 'calls the appropriate git command' do
        expect(@dummy_class).to receive(:`).with(git_string)
          .and_return('foo')
        @dummy_class.project_root
      end

      describe 'result' do
        let(:test_root) { '/test_root' }

        before do
          allow(@dummy_class).to receive(:`).with(git_string)
            .and_return(test_root)
        end

        it 'should return a programmatically-determined project_root' do
          expect(@dummy_class.project_root).to eq('/test_root')
        end
      end
    end
  end
end
