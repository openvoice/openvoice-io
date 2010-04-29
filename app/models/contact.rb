# class Contact < ActiveRecord::Base
#   belongs_to :user
# end

class Contact 
  # belongs_to :user
  include DataMapper::Resource
  
  property :id,           Serial
  property :contactname,  String
  property :number,       Text
  property :im,           String
  property :user_id,      Integer
  property :created_at,   DateTime
  property :updated_at,   DateTime
end