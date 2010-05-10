require "tropo-webapi-ruby"

class IncomingCallController < ApplicationController

  def index

    return head 400 if params[:session] == nil
                                                                                                                
    called_id = params[:session][:to][:id]
    profile = Profile.first(:voice => called_id)

    return head 404 if profile == nil

    user = profile.user

    return head 404 if user == nil

    caller_id = params[:session][:from][:id]
    contact = Contact.first(:user_id => user.id, :number=> caller_id)

    if(contact != nil && (contact.recording != nil || !contact.call_screening?))
      tropo = Tropo::Generator.new do
        on(:event => 'continue', :next => "/incoming_call/start_transfer?user_id=#{user.id}&caller_id=#{caller_id}")
      end
      render :json => tropo.response
      return      
    end

    #if(!user.call_screening?)
    #  return redirect_to "/incoming_call/start_transfer?user_id=#{user.id}&caller_id=#{caller_id}"
    #end

    tropo = Tropo::Generator.new do
      on(:event => 'hangup', :next => "hangup")
      on(:event => 'incomplete', :next => "hangup")
      on(:event => 'continue', :next => "/incoming_call/start_transfer?user_id=#{user.id}&caller_id=#{caller_id}")
      record( :attempts => 2,
           :beep => true,
           :name => 'record-name',
           :url => "#{SERVER_URL}/incoming_call/store_contact_recording?user_id=#{user.id}&caller_id=#{caller_id}",
           :format => "audio/mp3",
           :choices => "#",
           :say => { :value => "Before being connected please record your name" })
    end

    render :json => tropo.response

  end

  def store_contact_recording

    require 'appengine-apis/images'

    user_id = params[:user_id]
    caller_id = params[:caller_id]

    user = User.get(user_id)

    contact = Contact.first(:user_id => user_id, :number => caller_id)

    if(contact == nil)
      contact = Contact.new
      contact.attributes = {
        :contactname => caller_id,
        :user_id => user_id,
        :number => caller_id,
        :user => user
      }
    end

    contact.recording = AppEngine::Images.load(params[:filename].read)
    contact.save

    render :content_type => 'text/plan', :text => "STORED"

  end

  def get_contacts

    puts Contact.all.each_with_index {|c, index|
      puts "#{index} #{c.user_id} #{c.number}"
    }

  end


  def get_contact_recording

    require 'appengine-apis/images'

    user_id = params[:user_id]
    caller_id = params[:caller_id]

    contact = Contact.first(:user_id => user_id.to_i, :number => caller_id)

    if(contact == nil)
      head 404
      return
    end

    send_data (contact.recording, :type => 'audio/mp3', :filename => 'message.mp3', :disposition => 'inline')

  end

  def start_transfer

    caller_id = params[:caller_id]
    user_id = params[:user_id]

    call_url = "#{TROPO_API_URL}/sessions?action=create&token=#{OUTBOUND_VOICE_TEMP}&caller_id=#{params[:caller_id]}&user_id=#{params[:user_id]}&dialog=user_menu"

    begin
      AppEngine::URLFetch.fetch(call_url, :method => :get, :deadline => 10)
    rescue Exception=>e
      logger.error e
    end

    tropo = Tropo::Generator.new do
      on(:event => 'fail', :next => "hangup", :say => {:value => "Failed to connect"})
      conference( :name => "conference", :id => user_id + "<--->" + caller_id)
    end

    render :json => tropo.response

  end

  def token

    user_id = params[:session][:parameters][:user_id]
    caller_id = params[:session][:parameters][:caller_id]

    #user = User.get(user_id)

    tropo = Tropo::Generator.new do
      call( :to => "sip:bling@192.168.11.7")
      say("Incoming call from #{SERVER_URL}/incoming_call/get_contact_recording?caller_id=#{caller_id}&amp;user_id=#{user_id}")
      conference(:name => "conference", :id => user_id + "<--->" + caller_id)
    end

    render :json => tropo.response

  end

  def hangup
    tropo = Tropo::Generator.new do
      hangup()
    end
    render :json => tropo.response
  end

end
