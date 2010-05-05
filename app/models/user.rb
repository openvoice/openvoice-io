# class User < ActiveRecord::Base
#   acts_as_authentic
# 
#   has_many :phone_numbers
#   has_many :voicemails
#   has_many :messagings
#   has_many :voice_calls
#   has_many :contacts
#   has_many :profiles
# end


class User 
  # has_many :phone_numbers
  # has_many :voicemails
  # has_many :messagings
  # has_many :voice_calls
  # has_many :contacts
  # has_many :profiles
  
  # belongs_to :user
  include DataMapper::Resource
  
  property :id, Serial
  property :email,                  String,           :required => true
  property :apikey,                 String
  property :nickname,               String
  property :created_at,             DateTime
  property :updated_at,             DateTime

end
