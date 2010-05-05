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
#
#
# Ruby interface to the Java ApiProxy.

module AppEngine
  if defined? Java
    import com.google.apphosting.api.ApiProxy
  
    class << ApiProxy
      def version
        version_id = get_current_environment.getVersionId
        version_id[0,version_id.rindex(".").to_i] # nil to 0
      end 

      def app_id
        get_current_environment.getAppId
      end
      alias :get_app_id :app_id

      def auth_domain
        get_current_environment.getAuthDomain
      end
      alias :get_auth_domain :auth_domain
    
      alias :add_log_record :log
      def log(level, message)
        message = (message || "").to_s.chomp
        return if message.nil? || message.empty?
        record = AppEngine::ApiProxy::LogRecord.new(
            level, java.lang.System.currentTimeMillis() * 1000, message.to_s)
        add_log_record(record)
      end

    end
  end
end

