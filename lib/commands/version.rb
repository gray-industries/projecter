class ProjecterCLI < Thor
  desc 'version', 'show projecter version'
  def version
    puts "projecter #{Projecter::VERSION}"
  end
end
