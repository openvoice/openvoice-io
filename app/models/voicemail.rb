class Voicemail 
  include DataMapper::Resource  
  
  property :id,           Serial
  property :from,         String
  property :to,           String
  property :text,         String
  property :filename,     String
  property :data,         Blob
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime
  
  belongs_to :user
end
