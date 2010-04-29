# patch for -- dm-core 0.10.2 & rails 2.3.5
require 'dm-core'
require 'dm-ar-finders'
require 'dm-timestamps'
require 'dm-validations'
DataMapper.setup(:default, "appengine://auto")

require 'rails_dm_datastore/data_mapper'
require 'rails_dm_datastore/local_object_space'
require 'rails_dm_datastore/extlib'
require 'rails_dm_datastore/action_view'

# DataMapper::Validate
class Dictionary; alias count length; end

