# class Profile < ActiveRecord::Base
#   belongs_to :user
# end

class Profile 
  # belongs_to :user
  include DataMapper::Resource
  
  property :id, Serial
  property :voice,  String
  property :skype,  String
  property :sip,  String
  property :inum,     String
  property :tropo,     String
  property :twitter,     String
  property :gtalk,     String
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end