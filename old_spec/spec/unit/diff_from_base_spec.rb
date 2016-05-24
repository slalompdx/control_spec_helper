require 'spec_helper'

class DummyClass
  include ControlSpecHelper
end

describe 'control_spec_helper' do
  before do
    @dummy_class = DummyClass.new
  end

  describe 'when diff_from_base is called' do
    git_command = 'git diff production --cached --diff-filter=ACMR --name-only'

    it 'should call the appropriate git command' do
      @dummy_class.basebranch = 'production'
      expect(@dummy_class).to receive(:`).with(git_command)
        .and_return("a\nb\nc")
      @dummy_class.diff_from_base
    end

    describe 'result' do
      before do
        @dummy_class.basebranch = 'production'
        allow(@dummy_class).to receive(:`).with(git_command)
          .and_return("a\nb\nc")
      end

      it 'should return an array' do
        expect(@dummy_class.diff_from_base).to eq(%w(a b c))
      end
    end
  end
end
