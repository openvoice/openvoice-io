class SysConfig 
  include DataMapper::Resource
  
  property :id,           Serial
  property :voice_token,  Text
  property :sms_token,    Text
  property :server_url,   Text
  property :created_at,   DateTime
  property :updated_at,   DateTime
  
  validates_present :voice_token
  validates_present :sms_token
  validates_present :server_url
  
end
