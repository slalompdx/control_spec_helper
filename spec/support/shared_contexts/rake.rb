require 'rake'
require 'English'
require 'control_spec_helper/util'

shared_context 'rake' do
  Dir.chdir('fixtures/puppet-control') do
    let(:rake)       { Rake::Application.new }
    let(:task_name)  { self.class.top_level_description }
    let(:task_path)  { "lib/tasks/#{task_name.split(':').first}" }
    let(:ssh_config) { vagrant_ssh_config }
    subject          { rake[task_name] }

    def loaded_files_excluding_current_rake_file
      $LOADED_FEATURES.reject do |file|
        file == Rails_root.join("#{task_path}.rake").to_s
      end
    end

    before do
      Rake.application = rake
      Rake.application.rake_require(
        task_path, [Rails_root.to_s], loaded_files_excluding_current_rake_file
      )
    end
  end
end
