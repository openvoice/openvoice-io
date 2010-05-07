class PhoneNumber 
  include DataMapper::Resource
  
  property :id,           Serial
  property :number,       String
  property :description,  String
  property :forward,      Boolean
  property :smscapable,   Boolean
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :user
  validates_present :number
  validates_is_unique :number
end

