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
      describe 'result' do
        it 'should return a programmatically-determined project_root' do
          allow(@dummy_class).to receive(:file_name).and_return('/tmp/foo.rb')
          expect(@dummy_class.project_root).to eq('/tmp')
        end
      end
    end
  end
end
