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
  # property :login,                String,           :required => true, :length => 500
  # property :password,             String,           :required => true
  property :email,                String,           :required => true
  # property :salt,                 String,           :required => true
  # property :crypted_password,     String,           :required => true
  # property :password_salt,        String,           :required => true
  # property :persistence_token,    String,           :required => true
  # property :single_access_token,  String,           :required => true
  # property :perishable_token,     String,           :required => true, :length => 500
  # property :login_count,          String,           :required => true
  # property :failed_login_count,   String,           :required => true
  # property :last_request_at,      DateTime,             :required => true
  # property :current_login_at,     DateTime,             :required => true
  # property :last_login_at,        DateTime,             :required => true
  # property :current_login_ip,     String,           :required => true
  # property :last_login_ip,        String,           :required => true
  # property :created_at,           DateTime,             :required => true
  # property :updated_at,           DateTime,             :required => true
  # property :remember_token,       String,           :required => true
  # property :remember_token_expires_at,      DateTime,   :required => true
#  # timestamps :at


end
