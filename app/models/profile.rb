class Profile 
  include DataMapper::Resource
  
  property :id,             Serial
  property :voice,          String
  property :skype,          String
  property :sip,            String
  property :inum,           String
  property :tropo,          String
  property :twitter,        String
  property :gtalk,          String
  property :call_screening, Boolean
  property :voice_token,    Text
  property :sms_token,      Text  
  property :user_id,        Integer
  property :created_at,     DateTime
  property :updated_at,     DateTime

  belongs_to :user
  validates_present     :voice
  validates_present     :voice_token
  validates_present     :sms_token
end