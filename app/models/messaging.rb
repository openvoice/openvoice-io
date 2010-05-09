# class Messaging < ActiveRecord::Base
#   after_create :send_text
# 
#   def send_text
#     if outgoing
#       msg_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_MESSAGING_TEMP + '&from='+ from + '&to=' + to + '&text=' + CGI::escape(text)
#       open(msg_url) do |r|
#         p r
#       end
#     end
#   end
# end

class Messaging 
  include DataMapper::Resource
  
  property :id,           Serial
  property :from,         String
  property :to,           String
  property :text,         String
  property :outgoing,     Boolean
  property :user_id,      Integer #, :key => true, :index => true
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :user
end