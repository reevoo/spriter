Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "spriter"
  s.version           = "0.13.0"
  s.summary           = "Makes CSS sprites easy."
  s.author            = "Reevoo"
  s.homepage          = "http://www.reevoo.com"

  s.has_rdoc          = false

  # Add any extra files to include in the gem (like your README)
  s.files             = %w(Rakefile) + Dir.glob("{README*,test,lib/**/*}")
  s.require_paths     = ["lib"]

  s.add_dependency("mini_magick")
  s.add_development_dependency("rake")
  s.add_development_dependency("shoulda")
  s.add_development_dependency("mocha")
end
