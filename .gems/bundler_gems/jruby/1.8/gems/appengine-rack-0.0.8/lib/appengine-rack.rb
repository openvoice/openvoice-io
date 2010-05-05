#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2009 Google Inc.
# Original Author:: Ryan Brown (mailto:ribrdb@google.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rack'

begin
  require 'appengine-apis/urlfetch'
  require 'appengine-apis/tempfile'
rescue Exception
end

class ::Rack::Builder

  def skip_rack_servlet
    @skip_defaults = true
  end

  def mime_mapping(mapping)
    @mime_mapping = mapping
  end

end

module AppEngine
  module Rack
    ROOT = File.expand_path(File.dirname(__FILE__))
    
    class Resources
      COMMON_EXCLUDES = { 
          :rails_excludes => %w(README Rakefile db/** doc/** bin/**
                             log/** script/** test/** tmp/**),
          :merb_excludes => %w(Rakefile autotest/** doc/** bin/**
                             gems/** spec/**) }

      def initialize
        @includes = []
        @excludes = []
      end
    
      def include(glob, expiration=nil)
        if glob.is_a? Array
          glob.each do |g|
            @includes << [g, expiration]
          end
        else
          @includes << [glob, expiration]
        end
      end
    
      def exclude(glob)
        if glob.is_a? Array
          @excludes += glob
        elsif glob.is_a? Symbol
          @excludes += COMMON_EXCLUDES[glob]
        else
          @excludes << glob
        end
      end
    
      def append_to(xml, type)
        resources = xml.add_element(type) 
        @includes.each do |path, expiration|
          element = resources.add_element('include')
          element.add_attribute('path', path)
          element.add_attribute('expiration', expiration) if expiration
        end
        @excludes.each do |path|
          resources.add_element('exclude').add_attribute('path', path)
        end
      end
    end
  
    class PropertyMap < Hash
      def append_to(xml)
        unless empty?
          sys = xml.add_element('system-properties') 
          each do |name, value|
            sys.add_element('property').
                add_attributes( { "name" => name, "value" => value.to_s } )
          end
        end
      end
    end
  
    class EnvVarMap < Hash
      def append_to(xml)
        unless empty?
          env = xml.add_element('env-variables') 
          each do |name, value|
            env.add_element('env-var').
                add_attributes( { "name" => name, "value" => value.to_s } )
          end
        end
      end    
    end

    # Split loading requests into 3 parts
    #
    # deferred_dispatcher = AppEngine::Rack::DeferredDispatcher.new(
    #     :require => File.expand_path('../config/environment', __FILE__),
    #     :dispatch => 'ActionController::Dispatcher')
    # 
    # map '/admin' do
    #   use AppEngine::Rack::AdminRequired
    #   run deferred_dispatcher
    # end
    #
    # map '/' do
    #   use AppEngine::Rack::LoginRequired
    #   run deferred_dispatcher
    # end

    class DeferredDispatcher
      def initialize args
        @args = args
      end
 
      def call env
        if @runtime.nil?
          @runtime = true
          # 1: redirect with runtime and jruby-rack loaded
          redirect_or_error(env)
        elsif @rack_app.nil?
          require @args[:require]
          @rack_app = Object.module_eval(@args[:dispatch]).new
          # 2: redirect with framework required & dispatched
          redirect_or_error(env)
        else
          # 3: process all other requests
          @rack_app.call(env)
        end
      end
 
      def redirect_or_error(env)
        if env['REQUEST_METHOD'].eql?('GET')
          redir_url = env['REQUEST_URI'] +
              (env['QUERY_STRING'].eql?('') ? '?' : '&') + Time.now.to_i.to_s
          res = ::Rack::Response.new('*', 302)
          res['Location'] = redir_url
          res.finish
        else
          ::Rack::Response.new('Service Unavailable', 503).finish
        end
      end
    end
  

    class RackApplication
      attr_accessor :application, :inbound_services, :precompilation_enabled
      attr_reader :version, :static_files, :resource_files, :public_root
      attr_reader :system_properties, :environment_variables
      attr_writer :ssl_enabled, :sessions_enabled
    
      def initialize
        @version = '1'
        @system_properties = PropertyMap[ 'os.arch' => '',
            'jruby.jit.threshold'         => 99,
            'jruby.native.enabled'        => false,
            'jruby.management.enabled'    => false,
            'jruby.rack.input.rewindable' => false ]
        @environment_variables = EnvVarMap.new
        @static_files = Resources.new
        @resource_files = Resources.new
        @public_root = '/public'
        @inbound_services = []
      end
    
      alias id application
    
      def sessions_enabled?
        @sessions_enabled
      end
    
      def ssl_enabled?
        @ssl_enabled
      end
      
      def precompilation_enabled?
        @precompilation_enabled
      end

      def public_root=(root)
        root = "/#{root}".squeeze '/'
        root = nil if root.eql? '/'
        @public_root = root
      end
    
      def version=(version)
        @version = version.to_s
      end
    
      def configure(options={})
        [:system_properties, :environment_variables].each do |key|
          self.send(key).merge!(options.delete(key)) if options[key]
        end
        options.each { |k,v| self.send("#{k}=", v) }
      end
    
      def to_xml
        require 'rexml/document'

        xml = REXML::Document.new.add_element('appengine-web-app')
        xml.add_attribute('xmlns','http://appengine.google.com/ns/1.0')
        xml.add_element('application').add_text(application)
        xml.add_element('version').add_text(version)
        xml.add_element('public-root').add_text(@public_root) if @public_root
        static_files.append_to(xml, 'static-files')
        resource_files.append_to(xml, 'resource-files')
        system_properties.append_to(xml)
        environment_variables.append_to(xml)
        if sessions_enabled?
          xml.add_element('sessions-enabled').add_text('true')
        end
        if ssl_enabled?
          xml.add_element('ssl-enabled').add_text('true')
        end
        if precompilation_enabled?
          xml.add_element('precompilation-enabled').add_text('true')
        end
        unless @inbound_services.empty?
          services = xml.add_element('inbound-services')
          @inbound_services.each do |service|
            services.add_element('service').add_text(service.to_s)
          end
        end
        return xml
      end
    end
    
    class SecurityMiddleware
      def self.append_xml(doc, pattern)
        security = doc.add_element('security-constraint')
        collection = security.add_element('web-resource-collection')
        collection.add_element('url-pattern').add_text(pattern)
        collection.add_element('url-pattern').add_text(
            AppEngine::Rack.make_wildcard(pattern))
        yield security
      end

      def self.new(app, *args, &block)
        app
      end      
      
    end
    
    class AdminRequired < SecurityMiddleware
      def self.append_xml(doc, pattern)
        super(doc, pattern) do |security|
          auth = security.add_element('auth-constraint')
          auth.add_element('role-name').add_text('admin')
        end
      end
    end
  
    class LoginRequired < SecurityMiddleware
      def self.append_xml(doc, pattern)
        super(doc, pattern) do |security|
          auth = security.add_element('auth-constraint')
          auth.add_element('role-name').add_text('*')
        end
      end
    end

    class SSLRequired < SecurityMiddleware
      def self.append_xml(doc, pattern)
        super(doc, pattern) do |security|
          udc = security.add_element('user-data-constraint')
          udc.add_element('transport-guarantee').add_text('CONFIDENTIAL')
        end
      end
    end  

    class << self
      def app
        @app ||= RackApplication.new
      end

      def configure_app(options={})
        @app = RackApplication.new
        @app.configure(options)
      end

      # Deprecated, use ENV['RACK_ENV'] instead
      def environment
        if !$servlet_context.nil? and
            $servlet_context.server_info.include? 'Development'
          'development'
        else
          'production'
        end
      end
      
      def make_wildcard(pattern)
        "#{pattern}/*".squeeze('/')
      end
    end
  end
end
