# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{appengine-apis}
  s.version = "0.0.14"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Brown"]
  s.date = %q{2010-04-12}
  s.description = %q{Ruby API wrappers for App Engine}
  s.email = %q{ribrdb@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "COPYING"]
  s.files = ["COPYING", "README.rdoc", "Rakefile", "lib/appengine-apis/apiproxy.rb", "lib/appengine-apis/datastore.rb", "lib/appengine-apis/datastore_types.rb", "lib/appengine-apis/images.rb", "lib/appengine-apis/labs/taskqueue.rb", "lib/appengine-apis/local_boot.rb", "lib/appengine-apis/logger.rb", "lib/appengine-apis/mail.rb", "lib/appengine-apis/memcache.rb", "lib/appengine-apis/merb-logger.rb", "lib/appengine-apis/runtime.rb", "lib/appengine-apis/sdk.rb", "lib/appengine-apis/tempfile.rb", "lib/appengine-apis/testing.rb", "lib/appengine-apis/urlfetch.rb", "lib/appengine-apis/users.rb", "lib/appengine-apis/xmpp.rb", "lib/appengine-apis.rb", "lib/imagescience.rb", "spec/datastore_spec.rb", "spec/datastore_types_spec.rb", "spec/logger_spec.rb", "spec/mail_spec.rb", "spec/memcache_spec.rb", "spec/spec_helper.rb", "spec/taskqueue_spec.rb", "spec/urlfetch_spec.rb", "spec/users_spec.rb", "spec/xmpp_spec.rb"]
  s.homepage = %q{http://code.google.com/p/appengine-jruby}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby API wrappers for App Engine}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<appengine-rack>, [">= 0"])
    else
      s.add_dependency(%q<appengine-rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<appengine-rack>, [">= 0"])
  end
end
