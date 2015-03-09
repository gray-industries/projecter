require 'thor'
require 'find'

class ProjecterCLI < Thor
  # The create command is responsible for driving project creation.
  # XXX: This should be simpler. Eventually refactor once we have
  # composable projects, different project types besides lib/thorapp.

  include Thor::Actions
  add_runtime_options!
  source_root(File.expand_path('../../..', __FILE__))

  desc 'create PROJECT', 'Create a new Thor CLI skeleton in ./PROJECT'
  method_options uses_templates: false, uses_files: false, library: false

  # rubocop:disable Metrics/AbcSize
  def create(project)
    @project = project

    run("git init #{@project}", capture: true) unless File.exist?(File.join(@project, '.git'))

    create_project_dirs

    projecter_file(
      'Gemfile' => 'Gemfile',
      'Guardfile' => 'Guardfile',
      'Rakefile' => 'Rakefile',
      'dot-gitignore' => '.gitignore',
      'dot-metrics' => '.metrics',
      'dot-rspec' => '.rspec',
      'dot-rubocop.yml' => '.rubocop.yml'
    )

    lib_templates = {
      'gemspec.tt' => "#{project}.gemspec",
      'README.md.tt' => 'README.md',
      'LICENSE.md.tt' => 'LICENSE.md',
      'mainlib.rb.tt' => ['lib', "#{project}.rb"],
      'version.rb.tt' => ['lib', project, 'version.rb'],
      'spec_helper.rb.tt' => %w(spec spec_helper.rb),
      'spec_fixtures.rb.tt' => %w(spec fixtures.rb),
      'spec_resources.rb.tt' => %w(spec resources.rb)
    }

    app_templates = {
      'mainapp.tt' => ['bin', project],
      'version-cmd.rb.tt' => %w(lib commands version.rb)
    }

    templates = lib_templates
    templates.merge!(app_templates) unless options.library?

    projecter_template(
      templates,
      project: project,
      classname: project
                   .split(/[_-]/)
                   .map(&:capitalize)
                   .join,
      library_only: options.library?
    )

    inside(@project) do
      # XXX: KLUDGE: Add an empty .gitignore file in each empty directory
      # XXX: KLUDGE: so that git can track the dir.
      Find.find('.') do |path|
        next if path.start_with?('./.git/')
        next unless FileTest.directory?(path)
        next unless Dir.entries(path) == %w(. ..)

        create_file File.join(path, '.gitignore'), ''
      end

      run('git add .gitignore', capture: true)
      run('git add .', capture: true)
      run("git commit --allow-empty -m 'Created #{@project} using Projecter #{Projecter::VERSION}.'", capture: true)
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def projecter_file(mapping)
    mapping.each do |src, dst|
      copy_file(File.join('files', src), File.join(@project, dst))
    end
  end

  def projecter_template(mapping, bindings)
    mapping.each do |src, dst|
      dst = [dst] unless dst.is_a?(Array)

      srcname = File.join('templates', src)
      dstname = File.join(*[@project, dst].flatten)

      template(srcname, dstname, bindings)

      if dst.include?('bin')
        chmod(dstname, 0755) unless (File.stat(dstname).mode & 0755) == 0755
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def create_project_dirs
    source_dirs = ['lib', "lib/#{@project}"]
    %w(bin lib/commands).map { |d| source_dirs << d } unless options.library?

    test_resource_dirs = %w(fixtures resources)
    test_kinds = %w(unit integration acceptance)
    test_dirs = (test_resource_dirs + test_kinds.product(source_dirs)).map { |path| ['spec', path].join('/') }

    project_dirs = source_dirs + test_dirs
    project_dirs << 'templates' if options.uses_templates?
    project_dirs << 'files' if options.uses_files?

    project_dirs.each do |dir|
      empty_directory File.join(@project, dir)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def library?
    @library ||= options.library?
  end
end
