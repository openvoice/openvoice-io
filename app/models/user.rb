class User 
  include DataMapper::Resource
  
  property :id, Serial
  property :email,                  String,           :required => true
  property :apikey,                 String
  property :nickname,               String
  property :created_at,             DateTime
  property :updated_at,             DateTime
  property :call_screening?,        Boolean
  has n, :phone_numbers
  has n, :voicemails
  has n, :messagings
  has n, :voice_calls
  has n, :contacts
  has n, :profiles
  has n, :call_logs

end
