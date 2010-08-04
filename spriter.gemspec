Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "spriter"
  s.version           = "0.10.0"
  s.summary           = "Managers sprites and your css in a mega way."
  s.author            = "Reevoo"
  s.homepage          = "http://www.reevoo.com"

  s.has_rdoc          = false

  # Add any extra files to include in the gem (like your README)
  s.files             = %w(Rakefile) + Dir.glob("{README*,test,lib/**/*}")
  s.require_paths     = ["lib"]

  s.add_dependency("mini_magick")
  s.add_development_dependency("shoulda")
  s.add_development_dependency("mocha")
end