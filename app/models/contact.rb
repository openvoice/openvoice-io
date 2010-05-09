class Contact 
  include DataMapper::Resource
  
  property :id,           Serial
  property :contactname,  String
  property :number,       Text
  property :sip,          String
  property :inum,         String
  property :im,           String
  property :twitter,      String
  property :gtalk,        String
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :user
  validates_present :contactname
end