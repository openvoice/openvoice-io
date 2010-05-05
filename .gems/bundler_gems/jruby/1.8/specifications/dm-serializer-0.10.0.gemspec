# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-serializer}
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guy van den Berg"]
  s.date = %q{2009-09-16}
  s.description = %q{DataMapper plugin for serializing DataMapper objects}
  s.email = ["vandenberg.guy [a] gmail [d] com"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "TODO", "History.rdoc"]
  s.files = ["History.rdoc", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "TODO", "autotest/discover.rb", "autotest/dmserializer_rspec.rb", "benchmarks/to_json.rb", "benchmarks/to_xml.rb", "lib/dm-serializer.rb", "lib/dm-serializer/common.rb", "lib/dm-serializer/to_csv.rb", "lib/dm-serializer/to_json.rb", "lib/dm-serializer/to_xml.rb", "lib/dm-serializer/to_yaml.rb", "lib/dm-serializer/version.rb", "lib/dm-serializer/xml_serializers.rb", "lib/dm-serializer/xml_serializers/libxml.rb", "lib/dm-serializer/xml_serializers/nokogiri.rb", "lib/dm-serializer/xml_serializers/rexml.rb", "spec/fixtures/cow.rb", "spec/fixtures/planet.rb", "spec/fixtures/quan_tum_cat.rb", "spec/lib/serialization_method_shared_spec.rb", "spec/public/serializer_spec.rb", "spec/public/to_csv_spec.rb", "spec/public/to_json_spec.rb", "spec/public/to_xml_spec.rb", "spec/public/to_yaml_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/install.rb", "tasks/spec.rb"]
  s.homepage = %q{http://github.com/datamapper/dm-more/tree/master/dm-serializer}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{datamapper}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{DataMapper plugin for serializing DataMapper objects}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
