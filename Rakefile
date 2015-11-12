require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

require "rake/testtask"
Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

task :default => ["test"]

Gem::PackageTask.new(eval(File.read('spriter.gemspec'))) do |pkg|
end

# Generate documentation
Rake::RDocTask.new do |rd|

  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package]
