# class Voicemail < ActiveRecord::Base
#   belongs_to :user
# 
#   validates_presence_of :user
# 
# #  has_attachment :storage => :s3
# end

class Voicemail 
  # belongs_to :user
  include DataMapper::Resource
  
  
  property :id,           Serial
  property :from,         String
  property :to,           String
  property :text,         String
  property :filename,     String
  # property :message,      Object
  property :data,         Blob
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime
  
  
end
