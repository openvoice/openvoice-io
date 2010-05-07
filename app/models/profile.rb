class Profile 
  include DataMapper::Resource
  
  property :id,         Serial
  property :voice,      String
  property :skype,      String
  property :sip,        String
  property :inum,       String
  property :tropo,      String
  property :twitter,    String
  property :gtalk,      String
  property :user_id,    Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user
  validates_present     :voice
  # validates_is_unique   :voice
  # validates_is_unique   :skype
  # validates_is_unique   :sip
  # validates_is_unique   :inum
  # validates_is_unique   :tropo
  # validates_is_unique   :twitter
  # validates_is_unique   :gtalk
end