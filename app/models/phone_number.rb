# class PhoneNumber < ActiveRecord::Base
#   belongs_to :user
# 
#   validates_presence_of :user
# end

class PhoneNumber 
  # belongs_to :user
  include DataMapper::Resource
  
  property :id,           Serial
  property :number,       String
  property :description,  String
  property :forward,      Boolean
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime
end

