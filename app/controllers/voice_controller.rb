require "tropo-webapi-ruby"
require 'appengine-apis/images'

class VoiceController < ApplicationController

  def index

    return head 400 if !params[:session]

    if(!params[:session][:to])
      if params[:session][:parameters][:to]
        initiate_call
      else
        offer_call
      end
    else
      answer
    end

  end

  def answer

    x_voxeo_to = params["session"]["headers"]["x-voxeo-to"]
    sip_client = get_sip_client_from_header(x_voxeo_to)
    #profile = Profile.first(:voice => '1' + called_id )
    profile = locate_user(sip_client, x_voxeo_to)

    return head 404 if profile == nil

    user = profile.user
    called_id = params[:session][:to][:id]
    caller_id = params[:session][:from][:id]
    contact = Contact.first(:user_id => user.id, :number=> caller_id)

    call_id = params[:session][:callId]
    session_id = params[:session][:id]

    call_log = CallLog.new
    call_log.attributes = {
      :call_id => call_id,
      :from => caller_id,
      :to => called_id,
      :nature => "incoming",
      :user_id => user.id,
      :created_at => Time.now()
    }
    call_log.save

    if(contact && (contact.recording || !contact.call_screening))
      tropo = Tropo::Generator.new do
        on(:event => 'continue', :next => "/voice/start_transfer?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      end
      return render :json => tropo.response
    end

    if(!profile.call_screening)
      tropo = Tropo::Generator.new do
        on(:event => 'continue', :next => "/voice/start_transfer?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      end
      return render :json => tropo.response
    end

    sys_config = SysConfig.first

    tropo = Tropo::Generator.new do
      on(:event => 'incomplete', :next => "hangup")
      on(:event => 'continue', :next => "/voice/start_transfer?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      record( :attempts => 2,
           :beep => true,
           :name => 'record-name',
           :url => "#{sys_config.server_url}/voice/store_contact_recording?profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}",
           :format => "audio/mp3",
           :choices => {:terminator => "#"},
           :say => { :value => "Before being connected please record your name" })
    end

    render :json => tropo.response

  end

  def start_transfer

    profile_id = params[:profile_id]
    caller_id = params[:caller_id]
    call_id = params[:call_id]
    session_id = params[:session_id]

    profile = Profile.get(profile_id)

    sys_config = SysConfig.first

    fetch("#{sys_config.tropo_url}?action=create&token=#{profile.voice_token}&profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")

    tropo = Tropo::Generator.new do
      on(:event => 'disconnect', :next => "hangup")
      on(:event => 'voicemail', :next => "voicemail?profile_id=#{profile.id}&caller_id=#{caller_id}")
      say("Please wait while we connect your call")
      conference( :name => "conference", :id => profile_id + "<--->" + caller_id, :terminator => "*")
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
              :choices => {:terminator => "#"})
    end
    render :json => tropo.response

  end

  # OpenVoice User Call Handling and User Menu

  def offer_call

    profile_id = params[:session][:parameters][:profile_id]
    caller_id = params[:session][:parameters][:caller_id]
    call_id = params[:session][:parameters][:call_id]
    session_id = params[:session][:parameters][:session_id]

    sys_config = SysConfig.first
    user = Profile.get(profile_id).user

    forwarding_numbers = user.phone_numbers.collect {|num|
      num.number
    }

    tropo = Tropo::Generator.new do

      signal_url = "signal_peer?event=voicemail&call_id=#{call_id}&session_id=#{session_id}"

      on(:event => 'error', :next => signal_url)
      on(:event => 'hangup', :next => signal_url)
      on(:event => 'incomplete', :next => signal_url)
      on(:event => 'continue', :next => "user_menu_selection?profile_id=#{profile_id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      call( :to => forwarding_numbers)
      ask( :name => 'main_menu',
           :attempts => 2,
           :bargein => true,
           :choices => { :value => "connect(1), voicemail(2)", :mode => "DTMF" },
           :say => {:value => "Incoming call from #{sys_config.server_url}/voice/get_contact_recording?caller_id=#{caller_id}&amp;profile_id=#{profile_id} . Press 1 to connect. To send to voicemail press 2 or simply hangup."})
    end

    render :json => tropo.response

  end

  def user_menu_selection

    profile_id = params[:profile_id]
    caller_id = params[:caller_id]
    call_id = params[:call_id]
    session_id = params[:session_id]

    sys_config = SysConfig.first

    if params[:result][:actions][:value]
      selection = params[:result][:actions][:value]
    else
      selection = params[:result][:actions][:terminator]
    end

    if(selection == "ring")
      profile = Profile.get(profile_id)
      fetch("#{sys_config.tropo_url}?action=create&token=#{profile.voice_token}&profile_id=#{profile.id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
      selection = "connect"
    end

    record_operation = :none
    record_concept = "start_record"

    if(selection == "start_record")
      record_concept = "stop_record"
      record_operation = :start
      selection = "connect"
    elsif(selection == "stop_record")
      record_concept = "start_record"
      record_operation = :stop
      selection = "connect"
    end

    case selection
      when "connect"
        tropo = Tropo::Generator.new do
          signal_url = "signal_peer?event=disconnect&call_id=#{call_id}&session_id=#{session_id}"
          on(:event => 'error', :next => signal_url)
          on(:event => 'hangup', :next => signal_url)
          on(:event => 'continue', :next => "user_menu_selection?profile_id=#{profile_id}&caller_id=#{caller_id}&call_id=#{call_id}&session_id=#{session_id}")
          case record_operation
            when :start
              start_recording(:name => "recording",
                :format => "audio/mp3",
                :url => "#{sys_config.server_url}/voice/store_call_recording?call_id=#{call_id}"
              )
              say("Call recording enabled")
            when :stop
              stop_recording()
              say("Call recording disabled")
          end
          conference(:name => "conference",
                     :id => profile_id + "<--->" + caller_id,
                     :terminator => "ring(*), #{record_concept}(4)"
          )
        end
      when "voicemail"
        fetch("#{sys_config.tropo_url}/#{session_id}/calls/#{call_id}/events?action=create&name=voicemail")
        tropo = Tropo::Generator.new {hangup}
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
    head 204
  end

  def store_call_recording

    call_id = params[:call_id]
    call = CallLog.first(:call_id => call_id)

    return head 404 if call == nil

    recording = CallRecording.new
    recording.attributes = {
        :data  => AppEngine::Images.load(params[:filename].read),
        :created_at => Time.now,
        :call_log => call
    }
    recording.save

    render :content_type => 'text/plan', :text => "STORED"
  end


  # Outbound

  def initiate_call

    from = params[:session][:parameters][:from]
    if from[0..0] != "+"
      from = "+" + from
    end

    to = params[:session][:parameters][:to]
    if to[0..0] != "+"
      to = "+" + to
    end

    tropo = Tropo::Generator.new do
      call({ :from => to,
      :to => from,
      :network => 'PSTN',
      :channel => 'VOICE' })
      say 'connecting your call!'
      transfer({ :to => to , :from => from})
    end

    render :json => tropo.response
  end

  def get_sip_client_from_header(header)
    if header =~ /^<sip:990.*$/ #TODO Not detecting my Skype number in the database on locate_user.
      "SKYPE"
    elsif header =~ /^.*<sip:1999.*$/ # Only inluce first part of SIP number in DB prior to @ like 9991430371 (9991430371@sip.tropo.com)
      "SIP"
    elsif header =~ /^<sip:883.*$/
      "INUM"
    elsif header =~ /^.*<sip:|[1-9][0-9][0-9].*$/ # 14152739939
      "PSTN"
    else
      "OTHER"
    end
  end

  # TODO i'm not too happy with the implementation of this method, will revisit to refactor
  def locate_user(client, callee)

    logger.info "Locating profile [client=#{client}, calee=#{callee}]"

    profile = nil
    # profile = User.new
    if client == "SKYPE"
      number_to_search = "+" + %r{(^<sip:)(990.*)(@.*)}.match(callee)[2].delete(" ")
      # user = Profile.find_by_skype(number_to_search).user
      profile = Profile.find_by_skype(number_to_search)

    elsif client == "SIP"
      number_to_search = %r{(^<sip:)(.*)(@.*)}.match(callee)[2].sub("1", "")
      # profiles = Profile.all.select{ |profile| profile.sip.index(number_to_search) > 0}
      # user = !profiles.empty? && profiles.first.user
      profile = Profile.find_by_sip(number_to_search)

    elsif client == "PSTN"
      number_to_search = %r{(^<sip:)(.*)(@.*)}.match(callee)[2]
      # profiles = Profile.all.select{ |profile| profile.voice == number_to_search }
      # user = !profiles.empty? && profiles.first.user
      profile = Profile.find_by_voice(number_to_search)

    end

    profile
  end

  # Utility

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


end
