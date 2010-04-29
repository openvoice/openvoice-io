# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails_appengine}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Takeru Sasaki", "John Woodell"]
  s.date = %q{2010-03-01}
  s.description = %q{Config files for Rails on App Engine}
  s.email = ["sasaki.takeru@gmail.com", "woodie@netpress.com"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "lib/rails_appengine/action_mailer_vendored.rb", "lib/rails_appengine/active_support_conversions.rb", "lib/rails_appengine/active_support_vendored.rb", "lib/rails_appengine/bundler_boot.rb", "lib/rails_appengine/multiparameter_assignments.rb", "lib/rails_appengine.rb"]
  s.homepage = %q{http://github.com/takeru/rails_appengine}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{We intend to provide a common set of config files for Rails 2.3.5 (and eventually 3.0) on Google App Engine.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
