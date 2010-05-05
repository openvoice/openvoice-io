require 'appengine-rack'
# require 'cgi'
# require 'json'
# require 'dm-core'
# require 'dm-serializer'

AppEngine::Rack.configure_app(
    :application => 'myopenvoice',
    :precompilation_enabled => true,
    :sessions_enabled => true,
    :version => "1")

AppEngine::Rack.app.resource_files.exclude :rails_excludes
ENV['RAILS_ENV'] = AppEngine::Rack.environment

deferred_dispatcher = AppEngine::Rack::DeferredDispatcher.new(
    :require => File.expand_path('../config/environment', __FILE__),
    :dispatch => 'ActionController::Dispatcher')

map '/profiles' do
  use AppEngine::Rack::LoginRequired
  run deferred_dispatcher
end

# map '/admin' do
#   use AppEngine::Rack::AdminRequired
#   run deferred_dispatcher
# end

map '/' do
  run deferred_dispatcher
end
