# class CallLog < ActiveRecord::Base
# end

class CallLog 
  # belongs_to :user
  include DataMapper::Resource
  
  property :id,           Serial
  property :from,         String
  property :to,           String
  property :nature,       String
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime
end