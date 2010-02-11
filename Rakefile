require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"

require "rake/testtask"
Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

task :default => ["test"]

spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "spriter"
  s.version           = "0.8.0"
  s.summary           = "Managers sprites and your css in a mega way."
  s.author            = "Reevoo"
  s.homepage          = "http://www.reevoo.com"

  s.has_rdoc          = false

  # Add any extra files to include in the gem (like your README)
  s.files             = %w(Rakefile) + Dir.glob("{README*,test,lib/**/*}")
  s.require_paths     = ["lib"]

  s.add_development_dependency("shoulda")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec

  # Generate the gemspec file for github.
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# Generate documentation
Rake::RDocTask.new do |rd|

  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
