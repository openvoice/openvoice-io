as = "#{ENV['GEM_PATH']}/gems/activesupport-2.3.5/lib/active_support/vendor"
$LOAD_PATH.unshift "#{as}/builder-2.1.2"
$LOAD_PATH.unshift "#{as}/memcache-client-1.7.4"
$LOAD_PATH.unshift "#{as}/tzinfo-0.3.12"
$LOAD_PATH.unshift "#{as}/i18n-0.1.3/lib"
require 'builder'
require 'i18n'
