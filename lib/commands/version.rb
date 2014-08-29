class PuntyCLI < Thor
  desc "version", "show punty version"
  def version
    puts "punty #{Projecter::VERSION}"
  end
end
