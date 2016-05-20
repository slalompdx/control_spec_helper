# rubocop:disable Metrics/ModuleLength

require 'English'

# Test control repositories, similar to puppetlabs_spec_helper
module ControlSpecHelper
  attr_writer :basepath, :basebranch, :root

  def file_name
    __FILE__
  end

  def basepath
    @basepath ||= 'site'
  end

  def basebranch
    @basebranch ||= 'master'
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
    @role_path || File.join(project_root, basepath, 'role')
  end

  def profile_path
    @profile_path || File.join(project_root, basepath, 'profile')
  end

  def diff_from_base
    `git diff #{@basebranch} --cached --diff-filter=ACMR --name-only`
      .split("\n")
  end

  def diff_roles
    diff_from_base
      .select { |file| file.match(%r{site/role/manifests}) }
      .map { |path| class_from_path(path) }
  end

  def diff_profile
    diff_from_base
      .select { |file| file.match(%r{site/profile/manifests}) }
      .map { |path| class_from_path(path) }
  end

  # This is for role and profile modules only
  def class_from_path(path)
    return nil unless path =~ /manifests.+\.pp$/

    (path.sub(project_root + '/', '')
      .sub(/\.pp$/, '')
      .split('/') - %w(site manifests))
      .join('::')
  end

  def roles_that_include(klass)
    roles = ''
    Dir.chdir(role_path) do
      debug("cd to #{role_path}")
      roles = `git grep -l #{klass}`
              .split("\n")
              .map { |path| class_from_path(File.join(role_path, path)) }
              .compact
    end
    debug "cd to #{Dir.pwd}"
    roles
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
             { path: 'profile', type: nil }
           elsif klass =~ /role/
             { path: 'role', type: 'acceptance' }
           else
             raise ArgumentError
           end
    path = [project_root, basepath, test[:path], 'spec', test[:type]].compact
    File.join(path << (klass.split('::') - [test[:path]])) + '_spec.rb'
  end

  def r10k
    debug "cd to #{Dir.pwd}"
    Dir.chdir(project_root) do
      debug("cd to #{project_root}")
      puts 'Installing modules with r10k'
      `r10k puppetfile install`
    end
    $CHILD_STATUS.exitstatus
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def profile_fixtures
    Dir.chdir(profile_path) do
      debug(ENV['debug'])
      debug("cd to #{profile_path}")
      profile_ln = "#{Dir.pwd}/spec/fixtures/modules/profile"

      FileUtils.mkpath "#{Dir.pwd}/spec/fixtures/modules/"
      puts "===== #{profile_ln}"
      puts "===== #{profile_path}"
      puts "===== #{Dir.pwd}"
      puts "===== #{File.exist?(profile_ln)}"
      #File.symlink(profile_path, profile_ln) unless File.exist?(profile_ln)
      puts "====== REACHED PLACE 1 ======"
      puts "======= REACHED THE PLACE =======" unless File.exist?(profile_ln)

      Dir.glob("#{Dir.pwd}/../../modules/*").each do |folder|
        next unless File.directory?(folder)
        old_path = File.join(profile_path, '..', '..', 'modules',
                             File.basename(folder))
        new_path = "#{Dir.pwd}/spec/fixtures/modules/" \
          "#{File.basename(folder)}"
        File.symlink(old_path, new_path) unless File.symlink?(new_path)
      end
    end
    debug "cd to #{Dir.pwd}"
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def spec_clean
    Dir.chdir(project_root) do
      debug("cd to #{project_root}")
      fixtures = File.join(profile_path, 'spec', 'fixtures', 'modules')
      modules  = File.join(project_root, 'modules')

      abort if fixtures == '' || !fixtures
      abort if modules == '' || !modules

      FileUtils.rm_rf(fixtures)
      FileUtils.rm_rf(modules)
    end
    debug "cd to #{Dir.pwd}"
  end
  # rubocop:enable Metrics/AbcSize
end
