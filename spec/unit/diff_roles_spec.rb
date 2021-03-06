require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when diff_roles is called' do
    it 'should return a diff from base as an array' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      'a',
                      '/tmp/foo/site/role/manifests/foo.pp',
                      '/tmp/foo/site/role/manifests/bar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_roles)
        .and_return(['role::foo', 'role::bar'])
      @dummy_class.diff_roles
    end

    it 'should ignore classes in base that are not roles' do
      allow(@dummy_class).to receive(:diff_from_base)
        .and_return([
                      '/tmp/foo/site/profile/manifests/foo.pp',
                      '/tmp/foo/site/role/manifests/bar.pp',
                      '/tmp/foo/modules/baz/manifests/baz.pp',
                      '/tmp/foo/site/role/manifests/fubar.pp'
                    ])
      expect(@dummy_class).to receive(:diff_roles)
        .and_return(['role::bar', 'role::fubar'])
      @dummy_class.diff_roles
    end
  end
end
