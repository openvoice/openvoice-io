#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2010 Google Inc.
# Original Author:: John Woodell (mailto:woodie@google.com)
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

require 'jruby/rack/booter'

# try to require the bundled environment
begin
  require 'bundler_gems/environment'
rescue LoadError
  # continue
end

module JRuby
  module Rack
    class AppEngineLayout < WebInfLayout
      def app_uri
        @app_uri ||= '/'
      end

      def gem_path
        "bundler_gems/jruby/1.8"
      end

      def public_uri
        @public_uri ||= begin
          path = @rack_context.getInitParameter('public.root') || '/public'
          path = "/#{path}" unless path =~ %r{^/}
          path.chomp("/")
        end
      end

      def change_working_directory
        if @rack_context.server_info.include?('Development')
          ENV['RACK_ENV'] = 'development'
        else
          ENV['RACK_ENV'] = 'production'
        end
        super
      end
    end

    class Booter
      def default_layout_class
        AppEngineLayout
      end
    end
  end
end
