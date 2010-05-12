# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gdata}
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Fisher"]
  s.date = %q{2009-11-09}
  s.description = %q{This gem provides a set of wrappers designed to make it easy to work with 
the Google Data APIs.
}
  s.email = %q{jfisher@youtube.com}
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["LICENSE", "Rakefile", "README", "lib/gdata/auth/authsub.rb", "lib/gdata/auth/clientlogin.rb", "lib/gdata/auth.rb", "lib/gdata/client/apps.rb", "lib/gdata/client/base.rb", "lib/gdata/client/blogger.rb", "lib/gdata/client/booksearch.rb", "lib/gdata/client/calendar.rb", "lib/gdata/client/contacts.rb", "lib/gdata/client/doclist.rb", "lib/gdata/client/finance.rb", "lib/gdata/client/gbase.rb", "lib/gdata/client/gmail.rb", "lib/gdata/client/health.rb", "lib/gdata/client/notebook.rb", "lib/gdata/client/photos.rb", "lib/gdata/client/spreadsheets.rb", "lib/gdata/client/webmaster_tools.rb", "lib/gdata/client/youtube.rb", "lib/gdata/client.rb", "lib/gdata/http/default_service.rb", "lib/gdata/http/mime_body.rb", "lib/gdata/http/request.rb", "lib/gdata/http/response.rb", "lib/gdata/http.rb", "lib/gdata.rb", "test/tc_gdata_auth_authsub.rb", "test/tc_gdata_auth_clientlogin.rb", "test/tc_gdata_client_base.rb", "test/tc_gdata_client_calendar.rb", "test/tc_gdata_client_photos.rb", "test/tc_gdata_client_youtube.rb", "test/tc_gdata_http_mime_body.rb", "test/tc_gdata_http_request.rb", "test/test_helper.rb", "test/testimage.jpg", "test/ts_gdata.rb", "test/ts_gdata_auth.rb", "test/ts_gdata_client.rb", "test/ts_gdata_http.rb"]
  s.homepage = %q{http://code.google.com/p/gdata-ruby-util}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = %q{gdata}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Google Data APIs Ruby Utility Library}
  s.test_files = ["test/ts_gdata.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
