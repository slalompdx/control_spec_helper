require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when passed a file path' do
    describe 'if the path does not include manifests' do
      let(:path) { '/test_path/foobar.pp' }

      it 'should return nil' do
        expect(@dummy_class.class_from_path(path)).to eq(nil)
      end
    end

    describe 'if the path does not end in pp' do
      let(:path) { '/test_path/manifests/foobar' }
      it 'should return nil' do
        expect(@dummy_class.class_from_path(path)).to eq(nil)
      end
    end

    context 'when path is simple profile path' do
      let(:path) { '/test_path/site/profiles/manifests/klass.pp' }
      it 'should extrapolate a puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path)).to eq('profiles::klass')
      end
    end

    context 'when path is namespaced profile path' do
      let(:path) { '/test_path/site/profiles/manifests/klass/subklass.pp' }
      it 'should extrapolate a namespaced puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path))
          .to eq('profiles::klass::subklass')
      end
    end

    context 'when path is simple role path' do
      let(:path) { '/test_path/site/role/manifests/klass.pp' }
      it 'should extrapolate a puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path)).to eq('role::klass')
      end
    end

    context 'when path is namespaced role path' do
      let(:path) { '/test_path/site/role/manifests/klass/subklass.pp' }
      it 'should extrapolate a namespaced puppet class name' do
        allow(@dummy_class).to receive(:project_root).and_return('/test_path')
        expect(@dummy_class.class_from_path(path))
          .to eq('role::klass::subklass')
      end
    end
  end
end
