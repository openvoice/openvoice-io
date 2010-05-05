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
# Helpers for installing stub apis in unit tests.

module AppEngine

  # Local testing support for Google App Engine
  #
  # If you run your code on Google's servers or under dev_appserver,
  # the api's are already configured.
  #
  # To run outside this environment, you need to install a test environment and
  # api stubs.
  module Testing


    class << self
      def delegate # :nodoc:
        helper  # make sure everything's loaded
        require 'appengine-apis/apiproxy'
        AppEngine::ApiProxy.getDelegate
      end
      
      # The LocalServiceTestHelper used by this class.
      # Use this to set the logged in user, etc.
      def helper
        failed = false
        @helper ||= begin
          testing = Java::ComGoogleAppengineToolsDevelopmentTesting
          @datastore_config = testing::LocalDatastoreServiceTestConfig.new
          configs = [
            @datastore_config,
            testing::LocalBlobstoreServiceTestConfig.new,
            testing::LocalImagesServiceTestConfig.new,
            testing::LocalMailServiceTestConfig.new,
            testing::LocalMemcacheServiceTestConfig.new,
            testing::LocalTaskQueueTestConfig.new,
            testing::LocalURLFetchServiceTestConfig.new,
            testing::LocalUserServiceTestConfig.new,
            testing::LocalXMPPServiceTestConfig.new,
          ].to_java(testing::LocalServiceTestConfig)
          testing::LocalServiceTestHelper.new(configs)
        rescue => ex
          if failed
            raise ex
          else
            failed = true
            require 'appengine-sdk'
            AppEngine::SDK.load_local_test_helper
            retry
          end
        end
      end

      # Install stub apis and force all datastore operations to use
      # an in-memory datastore.
      #
      # You may call this multiple times to reset to a new in-memory datastore.
      def install_test_datastore
        self.persistent_datastore = false
        setup
      end

      def persistent_datastore
        helper
        !@datastore_config.is_no_storage
      end

      def persistent_datastore=(value)
        helper
        @datastore_config.set_no_storage(!value)
        setup
      end

      def setup
        if delegate
          teardown rescue nil
        end
        helper.setUp
      end

      def teardown
        helper.tearDown
      end

      # Loads stub API implementations if no API implementation is
      # currently configured.
      #
      # Sets up a datastore saved to disk in '.'.
      #
      # Does nothing is APIs are already configured (e.g. in production).
      #
      # As a shortcut you can use
      #   require 'appengine-apis/local_boot'
      # 
      def boot
        if delegate
          return
        end
        self.persistent_datastore = true
        setup
        at_exit {java.lang.System.exit(0)}
      end
    end

  end
end
