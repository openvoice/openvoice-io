require 'jruby/rack/version'
module JRubyJars
  def self.jruby_rack_jar_path
    File.expand_path("../jruby-rack-#{JRuby::Rack::VERSION}.jar", __FILE__)
  end
end
