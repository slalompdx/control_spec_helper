require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when passed a puppet class' do
    let(:klass) { 'klass' }
    it 'should be able to identify roles that contain that class' do
      allow(@dummy_class).to receive(:role_path).and_return('/')
      allow(@dummy_class).to receive(:project_root).and_return('/test_path')
      allow(@dummy_class).to receive(:`).with('git grep -l klass')
        .and_return("manifests/klass.pp\n" \
                    "manifests/klass/repo.pp\n" \
                    "manifests/stages.pp\n" \
                    "spec/classes/klass_spec.rb\n" \
                    "spec/classes/klass/repo_spec.rb\n" \
                    'spec/classes/stages_spec.rb')
      expect(@dummy_class.roles_that_include('klass'))
        .to eq(["::klass", "::klass::repo", "::stages"])
    end

    describe 'when asked to identify a spec file based on class name' do
      let(:klass) { 'profile::klass' }
      let(:role_klass) { 'role::klass' }
      it 'should fail if class is neither role nor profile' do
        expect { @dummy_class.spec_from_class('klass') }
          .to raise_error ArgumentError
      end

      context 'when passed a profile class' do
        it 'should be able to identify a spec file based on class name' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(klass))
            .to eq('/test_root/control_spec_helper/profile/spec/klass_spec.rb')
        end

        it 'should place a profile spec in the correct path' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(klass))
            .to eq('/test_root/control_spec_helper/profile/spec/klass_spec.rb')
        end

        it 'should place a role spec in the correct path' do
          allow(@dummy_class).to receive(:project_root).and_return('/')
          allow(@dummy_class).to receive(:basepath)
            .and_return('/test_root/control_spec_helper')
          expect(@dummy_class.spec_from_class(role_klass))
            .to eq('/test_root/control_spec_helper/role/spec/acceptance/klass_spec.rb')
        end
      end
    end
  end
end
