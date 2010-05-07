class Contact 
  include DataMapper::Resource
  
  property :id,           Serial
  property :contactname,  String
  property :number,       Text
  property :im,           String
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :user
  validates_present :contactname
end