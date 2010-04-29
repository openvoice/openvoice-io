class Rails::InfoController < ActionController::Base
  def properties
    info = [['Ruby version', "#{RUBY_VERSION} (#{RUBY_PLATFORM})"]]
    if defined? Gem::RubyGemsVersion
      info << ['RubyGems version', Gem::RubyGemsVersion]
    else
      info << ['RubyGems','disabled']
    end
    info << ['Rack version', Rack.release]
    # get versions from rails frameworks
    info << ['Rails version', Rails::VERSION::STRING]
    frameworks = %w{action_pack active_support}
    if defined? ActiveRecord
      frameworks.unshift('active_record')
      db_adapter =  ActiveRecord::Base.configurations[RAILS_ENV]['adapter']
    end
    frameworks.push('active_resource') if defined? ActiveResource
    frameworks.push('action_mailer') if defined? ActionMailer
    frameworks.each do |f|
      require "#{f}/version"
      info << [ "#{f.titlecase} version",
                "#{f.classify}::VERSION::STRING".constantize]
    end
    info << ['Bumble version', Bumble::VERSION] if defined? Bumble
    info << ['TinyDS version', TinyDS::VERSION] if defined? TinyDS
    info << ['DataMapper version', DataMapper::VERSION] if defined? DataMapper
    info << ['Environment', RAILS_ENV]
    info << ['Database adapter', db_adapter ] if defined? ActiveRecord
    info << ['Bundler version', Bundler::VERSION] if defined? Bundler::VERSION
    # get versions from jruby environment
    if defined?(JRuby::Rack::VERSION)
      info << ['JRuby Runtime version', JRUBY_VERSION]
      info << ['JRuby-Rack version', JRuby::Rack::VERSION]
    end
    # get information from app engine
    if defined?(AppEngine::ApiProxy)
      require 'appengine-apis' # for VERSION
      import com.google.appengine.api.utils.SystemProperty
      sdk = SystemProperty.version.get.to_s
      env = AppEngine::ApiProxy.current_environment
      ver = env.getVersionId[0,env.getVersionId.rindex(".")]
      info << ['AppEngine SDK version', sdk]
      info << ['AppEngine APIs version', AppEngine::VERSION]
      info << ['Auth domain', env.getAuthDomain]
      info << ['Application id:version', env.getAppId + ":#{ver}"]
    end
    # render as an HTML table
    html = "<table><tbody>"
    info.each { |k,v| html += "<tr><td>#{k}</td><td>#{v}</td></tr>" }
    html += "</tbody></table>"
    render :text => html
  end
end
