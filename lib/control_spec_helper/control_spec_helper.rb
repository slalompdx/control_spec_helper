# rubocop:disable Style/DotPosition, Style/HashSyntax

module ControlSpecHelper
  @@basepath='site'
  def set_basepath(new_basepath='site')
    @@basepath = new_basepath
  end
  def debug(msg)
    puts "DEBUG: #{msg}" if ENV['debug']
  end

  def puppet_cmd
    'puppet apply manifests/site.pp \
      --modulepath $(echo `pwd`/modules:`pwd`/site) --hiera_config hiera.yaml'
  end

  def project_root
    return @root if @root
    @root = `git rev-parse --show-toplevel`.chomp
    debug("project_root = #{@root}")
    @root
  end

  def role_path
    File.join(project_root, @@basepath, 'role')
  end

  def profile_path
    File.join(project_root, @@basepath, 'profile')
  end

  def diff_from_master
    `git diff master --cached --diff-filter=ACMR --name-only`.split("\n")
  end

  def diff_roles
    diff_from_master.
      select { |file| file.match(%r{site/role/manifests}) }.
      map { |path| class_from_path(path) }
  end

  def diff_profile
    diff_from_master.
      select { |file| file.match(%r{site/profile/manifests}) }.
      map { |path| class_from_path(path) }
  end

  def class_from_path(path)
    return nil unless path =~ /manifests.+\.pp$/

    (path.sub(project_root + '/', '').
      sub(/\.pp$/, '').
      split('/') - %w(site manifests)).
      join('::')
  end

  def roles_that_include(klass)
    Dir.chdir(role_path) do
      debug("cd to #{role_path}")
      `git grep -l #{klass}`.split("\n").
        map { |path| class_from_path(File.join(role_path, path)) }.
        compact
    end
    debug "cd to #{Dir.pwd}"
  end

  # TODO: this could be much more accurate if we compiled catalogs for all roles
  # and then parsed them for included Classes, but that is very complicated
  def all_roles_with_changes
    (diff_roles + diff_profile.map do |klass|
      roles_that_include(klass)
    end.flatten).uniq
  end

  def spec_from_class(klass)
    test = if klass =~ /profile/
             { :path => 'profile', :type => nil }
           elsif klass =~ /role/
             { :path => 'role', :type => 'acceptance' }
           else
             fail ArgumentError
           end

    path = [project_root, basepath, test[:path], 'spec', test[:type]].compact
    File.join(path << (klass.split('::') - [test[:path]])) + '_spec.rb'
  end

  def r10k
    Dir.chdir(project_root) do
      debug("cd to #{project_root}")
      puts 'Installing modules with r10k'
      `r10k puppetfile install`
    end
    debug "cd to #{Dir.pwd}"
  end

  def profile_fixtures
    Dir.chdir(profile_path) do
      debug("cd to #{profile_path}")
      profile_ln = './spec/fixtures/modules/profile'

      FileUtils.mkpath './spec/fixtures/modules/'
      File.symlink(profile_path, profile_ln) unless File.symlink?(profile_ln)

      Dir.glob('../../modules/*').each do |folder|
        next unless File.directory?(folder)
        old_path = File.join(File.dirname(__FILE__), folder)
        new_path = File.join("./spec/fixtures/modules/#{File.basename(folder)}")

        File.symlink(old_path, new_path) unless File.symlink?(new_path)
      end
    end
    debug "cd to #{Dir.pwd}"
  end

  def spec_clean
    Dir.chdir(project_root) do
      debug("cd to #{project_root}")
      fixtures = File.join(profile_path, 'spec', 'fixtures', 'modules')
      modules  = File.join(project_root, 'modules')

      abort if fixtures == '' || !fixtures
      abort if modules == '' || !modules

      `rm -rf #{fixtures}/*`
      `rm -rf #{modules}/*`
    end
    debug "cd to #{Dir.pwd}"
  end
end
