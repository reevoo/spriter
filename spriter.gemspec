# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{spriter}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Reevoo"]
  s.date = %q{2010-01-26}
  s.extra_rdoc_files = ["README"]
  s.files = ["Rakefile", "test", "lib/rack", "lib/rack/spriter.rb", "lib/spriter.rb", "README"]
  s.homepage = %q{http://www.reevoo.com}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Managers sprites and your css in a mega way.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end
