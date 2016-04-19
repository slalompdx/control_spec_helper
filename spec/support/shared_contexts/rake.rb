# spec/support/shared_contexts/rake.rb
require "rake"

shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { self.class.top_level_description }
  let(:task_path) { "lib/tasks/#{task_name.split(":").first}" }
  subject         { rake[task_name] }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == "#{File.dirname(__FILE__)}/../../../#{task_path}.rake" }
  end

  before do
    Rake.application = rake
    require 'pry'
    binding.pry
    Rake.application.rake_require(task_path, ["#{File.dirname(__FILE__)}/../../../lib"], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)
  end
end
