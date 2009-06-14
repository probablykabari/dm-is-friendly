# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-is-friendly}
  s.version = "0.9.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kabari Hendrick"]
  s.date = %q{2009-06-15}
  s.email = %q{manbehindtheman@kabari.name}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "dm-is-friendly.gemspec",
     "lib/dm-is-friendly.rb",
     "lib/is/friendly.rb",
     "lib/is/version.rb",
     "spec/dm-is-friendly_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/kabari/dm-is-friendly}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{DataMapper plugin that adds self-referential friendship functionality to your models.}
  s.test_files = [
    "spec/dm-is-friendly_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<extlib>, ["~> 0.9.11"])
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.9.11"])
      s.add_runtime_dependency(%q<dm-aggregates>, ["~> 0.9.11"])
    else
      s.add_dependency(%q<extlib>, ["~> 0.9.11"])
      s.add_dependency(%q<dm-core>, ["~> 0.9.11"])
      s.add_dependency(%q<dm-aggregates>, ["~> 0.9.11"])
    end
  else
    s.add_dependency(%q<extlib>, ["~> 0.9.11"])
    s.add_dependency(%q<dm-core>, ["~> 0.9.11"])
    s.add_dependency(%q<dm-aggregates>, ["~> 0.9.11"])
  end
end
