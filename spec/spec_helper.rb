require 'rspec'
require 'puppet-syntax'

def fixture_hiera(list)
  fixture_files(list, 'hieradata')
end

def fixture_modules_base(list)
  fixture_files(list, 'test_repo/dist')
end

def fixture_templates(list)
    fixture_files(list, 'test_repo/templates')
end

end
def fixture_manifests(list)
  fixture_files(list, 'test_repo/manifests')
end

def fixture_files(list, path)
  list = [list].flatten
  list.map { |f| File.expand_path("../fixtures/#{path}/#{f}", __FILE__) }
end

RSpec.configure do |config|
  config.color     = true
  config.formatter = 'documentation'
end
