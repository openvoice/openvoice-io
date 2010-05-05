# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Skip these so generators can run from MRI
  if defined? JRUBY_VERSION
    # Patch Rails Framework
    require 'rails_appengine'
    # Use DataMapper to access datastore
    require 'rails_dm_datastore'
    # Set Logger from appengine-apis, all environments
    require 'appengine-apis/logger'
    config.logger = AppEngine::Logger.new
    # Skip frameworks you're not going to use.
    config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  end
  # Skip plugin locators
  config.plugin_locators -= [Rails::Plugin::GemLocator]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  # OUTBOUND_MESSAGING_TEMP = "6495a7105bda7c41902027cb67c734c0445cbf5acade80d61b4b9a61b2097bdc62630ea6ef9f0854bb9d96a6"
  # OUTBOUND_VOICE_TEMP = "c7a69e058363c544bb52e93f69c5db3841d0736b971818dfbf6d5e6c4000526f41b269e9c06238899bd770f5"

  
  OUTBOUND_MESSAGING_TEMP = "4209df9d948c7a4bbeb07a8117c62b5f5614c13dd25919b855b08645dfeb69787685bb8bf3bb58456ee0ac17"
  OUTBOUND_VOICE_TEMP = "1556a3d0acbaee4b809d61d2630170de1ac687735f6d6f05ea7d616589c3eac49d2b09fc444b23fc1d4d825d"
  
end