require "tropo-webapi-ruby"
require 'appengine-apis/images'

class IncomingCallController < ApplicationController

  def index

    return head 400 if !params[:session]
                                                                                                                
    called_id = params[:session][:to][:id] rescue nil
    if called_id
      profile = Profile.first(:voice => '1' + called_id )
    end
    
    return head 404 if profile == nil

    user = profile.user
    caller_id = params[:session][:from][:id]
    contact = Contact.first(:user_id => user.id, :number=> caller_id)

    call_id = params[:session][:callId]
    session_id = params[:session][:id]

    call_log = CallLog.new
    call_log.attributes = {
      :from => caller_id,
      :to => called_id,
      :nature => "incoming",
      :user_id => user.id,
      :created_at => Time.now()
    }
    call_log.save

    if(contact != nil && (contact.recording != nil || !contact.call_screening))
      tropo = Tropo::Generator.new do
        on(:event => 'continue', :next => "/incoming_call/start_transfer?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      end
      render :json => tropo.response
      return      
    end

    if(!profile.call_screening)              
      tropo = Tropo::Generator.new do
        on(:event => 'continue', :next => "/incoming_call/start_transfer?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      end
      render :json => tropo.response
      return
    end

    sys_config = SysConfig.first

    tropo = Tropo::Generator.new do
      on(:event => 'hangup', :next => "hangup")
      on(:event => 'incomplete', :next => "hangup")
      on(:event => 'continue', :next => "/incoming_call/start_transfer?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      record( :attempts => 2,
           :beep => true,
           :name => 'record-name',
           :url => "#{sys_config.server_url}/incoming_call/store_contact_recording?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}",
           :format => "audio/mp3",
           :choices => {:value => "#"},
           :say => { :value => "Before being connected please record your name" })
    end

    render :json => tropo.response

  end

  def store_contact_recording

    profile_id = params[:profile_id]
    caller_id = params[:caller_id]

    profile = Profile.get(profile_id)

    contact = Contact.first(:user_id => profile.user_id, :number => caller_id)

    if(contact == nil)
      contact = Contact.new
      contact.attributes = {
        :contactname => caller_id,
        :user_id => profile.user_id,
        :number => caller_id,
        :user => profile.user
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

    profile_id = params[:profile_id]
    caller_id = params[:caller_id]

    profile = Profile.get(profile_id)

    contact = Contact.first(:user_id => profile.user_id, :number => caller_id)

    if(contact == nil)
      head 404
      return
    end

    send_data(contact.recording, :type => 'audio/mp3', :filename => 'message.mp3', :disposition => 'inline')

  end

  def start_transfer

    profile_id = params[:profile_id]
    caller_id = params[:caller_id]
    call_id = params[:call_id]
    session_id = params[:session_id]

    profile = Profile.get(profile_id)

    sys_config = SysConfig.first

    fetch("#{sys_config.tropo_url}?action=create&token=#{profile.voice_token}&profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}&dialog=user_menu")

    tropo = Tropo::Generator.new do
      on(:event => 'hangup', :next => "hangup")
      on(:event => 'voicemail', :next => "voicemail?profile_id=#{profile.id}&caller_id=#{caller_id}")
      conference( :name => "conference", :id => profile_id + "<--->" + caller_id, :terminator => "*")
    end

    render :json => tropo.response

  end

  def token

    profile_id = params[:session][:parameters][:profile_id]
    caller_id = params[:session][:parameters][:caller_id]
    call_id = params[:session][:parameters][:call_id]
    session_id = params[:session][:parameters][:session_id]
    dialog = params[:session][:parameters][:dialog]

    logger.debug "dialog=" + dialog
    case dialog
      when "user_menu"

        sys_config = SysConfig.first
        user = Profile.get(profile_id).user

        forawding_numbers = user.phone_numbers.collect {|num|
          num.number
        }

        signal_url = "signal_peer?event=voicemail&call_id=#{call_id}&session_id=#{session_id}"

        tropo = Tropo::Generator.new do
          on(:event => 'error', :next => signal_url)
          on(:event => 'hangup', :next => signal_url)
          on(:event => 'incomplete', :next => signal_url)
          on(:event => 'continue', :next => "user_menu_selection?profile_id=#{profile_id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
          call( :to => forawding_numbers)
          ask( :name => 'main_menu',
               :attempts => 2,
               :bargein => true,
               :choices => { :value => "connect(1), voicemail(2)", :mode => "DTMF" },
               :say => {:value => "Incoming call from #{sys_config.server_url}/incoming_call/get_contact_recording?caller_id=#{caller_id}&amp;profile_id=#{profile_id} . Press 1 to connect. To send to voicemail press two or simply hangup."})
        end
      else
        return head 400
    end

    render :json => tropo.response

  end

  def user_menu_selection
    
    profile_id = params[:profile_id]
    caller_id = params[:caller_id]
    call_id = params[:call_id]
    session_id = params[:session_id]
    
    sys_config = SysConfig.first

    selection = params[:result][:actions][:value]

    signal_url = "signal_peer?event=hangup&call_id=#{call_id}&session_id=#{session_id}"

    case selection
      when "connect"
        tropo = Tropo::Generator.new do
          on(:event => 'continue', :next => signal_url)
          conference(:name => "conference", :id => profile_id + "<--->" + caller_id)
        end
      when "voicemail"
        fetch("#{sys_config.tropo_url}/#{session_id}/calls/#{call_id}/events?action=create&name=voicemail")
        tropo = Tropo::Generator.new do
          hangup()
        end
      else
        return head 400
    end
    
    render :json => tropo.response
  end


  def signal_peer
    call_id = params[:call_id]
    session_id = params[:session_id]
    event = params[:event]
    sys_config = SysConfig.first
    fetch("#{sys_config.tropo_url}/#{session_id}/calls/#{call_id}/events?action=create&name=#{event}")
  end

  def hangup
    tropo = Tropo::Generator.new do
      hangup()
    end
    render :json => tropo.response
  end

  def fetch(url)
    begin
      logger.info "Fetching: #{url}"
      AppEngine::URLFetch.fetch(url, :method => :get,:deadline => 10)
    rescue Exception=>e
      logger.error e
    end
  end

  def voicemail

    sys_config = SysConfig.first

    profile_id = params[:profile_id]
    caller_id = params[:caller_id]

    profile = Profile.get(profile_id)

    tropo = Tropo::Generator.new do
      record( :say => [:value => "You've reached the mailbox of  #{profile.greeting_name}. Please leave your message after the tone."],
              :beep => true,
              :maxTime => 30,
              :format => "audio/mp3",
              :name => "voicemail",
              :url => sys_config.server_url + "/voicemails/create?caller_id=#{caller_id}&user_id=#{profile.user.id}",
              :choices => {:value => "#"})
    end
    render :json => tropo.response

  end
  
end
