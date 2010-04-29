# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jruby-rack}
  s.version = "0.9.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger"]
  s.date = %q{2010-04-04}
  s.description = %q{JRuby-Rack is a combined Java and Ruby library that adapts the Java Servlet API to Rack. For JRuby only.}
  s.email = ["nick@nicksieger.com"]
  s.files = ["./History.txt", "./LICENSE.txt", "./README.md", "./lib/jruby-rack-0.9.7.jar", "./lib/jruby-rack.rb", "./lib/jruby/rack/version.rb"]
  s.homepage = %q{http://jruby.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jruby-extras}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Rack adapter for JRuby and Servlet Containers}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
