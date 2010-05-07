# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-paginator}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Juan Felipe Alvarez Saldarriaga"]
  s.date = %q{2010-03-15}
  s.description = %q{Simple DataMapper paginator}
  s.email = %q{nebiros@gmail.com}
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = ["lib/dm-paginator.rb", "lib/dm-paginator/control.rb", "lib/dm-paginator/control/all.rb", "lib/dm-paginator/control/control_helper_abstract.rb", "lib/dm-paginator/control/elastic.rb", "lib/dm-paginator/control/jumping.rb", "lib/dm-paginator/control/sliding.rb", "lib/dm-paginator/default.rb", "lib/dm-paginator/main.rb", "lib/dm-paginator/paginator.rb", "lib/dm-paginator/version.rb", "LICENSE", "README.rdoc", "test/helper.rb", "test/test_dm-paginator.rb", "examples/paginator.rb"]
  s.homepage = %q{http://github.com/nebiros/dm-paginator}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A simple DataMapper paginator}
  s.test_files = ["test/helper.rb", "test/test_dm-paginator.rb", "examples/paginator.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<dm-core>, [">= 0.10.1"])
    else
      s.add_dependency(%q<dm-core>, [">= 0.10.1"])
    end
  else
    s.add_dependency(%q<dm-core>, [">= 0.10.1"])
  end
end
