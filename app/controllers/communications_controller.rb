require "tropo-webapi-ruby"

class CommunicationsController < ApplicationController
  def index
    
    if params[:session][:parameters] && params[:session][:parameters][:ov_action]
      ov_action = params[:session][:parameters][:ov_action]
      if ov_action == "call"
        render :json => init_voice_call.response
      end
      
    else
    
      headers = params["session"]["headers"]
      x_voxeo_to = headers["x-voxeo-to"]
      sip_client = get_sip_client_from_header(x_voxeo_to)
      from = params["session"]["from"]["id"]
      profile = locate_user(sip_client, x_voxeo_to)
      if profile
        user = User.find(profile.user_id)
      end
    
      if user
        user_name = user.nickname
        tropo = Tropo::Generator.new do
          say "hello, welcome to #{user_name}'s open voice communication center"
          on(:event => 'continue', :next => "answer?caller_id=#{from}@#{sip_client}&user_id=#{user.id}")
        
          ask( :attempts => 2,
               :bargein => true,
               :choices => { :value => "connect(connect, 1), voicemail(voicemail, 2)" },
               :name => 'main-menu',
               :say => { :value => "To speak to #{user_name}, say connect or press 1. To leave a voicemail, say voicemail or press 2." })

        end
      else
        tropo = Tropo::Generator.new do
          say "hello, welcome to open voice communication center. user is not on file."
        end
      end
    
      render :json => tropo.response
    end
  end

  def answer
    value = params[:result][:actions][:value]
    caller_id = params[:caller_id]
    user_id = params[:user_id]
    
    # CallLog.create(:from => caller_id, :to => "you", :nature => "incoming")
    call_log = CallLog.new
    call_log.attributes = {
      :from => caller_id,
      :to => "you",
      :nature => "incoming",
      :user_id => params[:user_id],
      :created_at => Time.now()
    }
    call_log.save
    
    # forward = User.find(params[:user_id]).phone_numbers.select{ |pn| pn.forward == true }.first
    # forward = User.find(params[:user_id])
    phonenumber = PhoneNumber.first(:user_id => params[:user_id], :forward => true) #TODO ring all phones 
  	if phonenumber
  	  firstnumber = phonenumber.number
  	  if firstnumber[0..0] != "+"
  	    firstnumber = "+" + firstnumber
  	  end
  	else
  	  firstnumber = '+14152739939'
  	end 

    # .phone_numbers.select{ |pn| pn.forward == true }.first
    # forward_number = forward && forward.number
    forward_number = firstnumber

      case value
      when 'connect'
        tropo = Tropo::Generator.new do
          say :value => 'connecting' 
          transfer({ # TODO where to send the incoming calls?  ring all phones?
                     :to => forward_number,
                     :ringRepeat => 3,
                     :timeout => 30,
                     :answerOnMedia => true,
                     # TODO figure out the correct caller_id when not pstn
                     :from => "14085059096"
          })
        end
        render :json => tropo.response

      when 'voicemail'
        tropo = Tropo::Generator.new do
          record( :say => [:value => 'please speak after the beep to leave a voicemail'],
                  :beep => true,
                  :maxTime => 30,
                  :format => "audio/mp3",
                  :name => "voicemail",
                  :url => SERVER_URL + "/voicemails/create?caller_id=#{caller_id}&user_id=#{user_id}")#,
#          :transcriptionOutURI => SERVER_URL + "/voicemails/set_transcription&voicemail_id=1",
#          :transcriptionID => '1234' )
        end
        render :json => tropo.response

      else
        tropo = Tropo::Generator.new do
          say "Please try again with keypad"
        end
        render :json => tropo.response
      end
  end


  def init_voice_call
    # call OV user first, once user answers, transfers the call to the destination number
    user_id = params[:session][:parameters][:user_id]
    # ov_voice = User.find(user_id).profiles.first.voice
    
    #     phonenumber = PhoneNumber.first(:user_id => user_id) 
    # if phonenumber
    #   firstnumber = phonenumber.number
    #       # if firstnumber[0..0] != "+"
    #       #   firstnumber = "+" + firstnumber
    #       # end
    # else
    #       # firstnumber = '+14152739939'
    #       firstnumber = '14152739939'
    # end 
    
    from = params[:session][:parameters][:from]
    if from[0..0] != "+"
      from = "+" + from
    end

    to = params[:session][:parameters][:to]
    if to[0..0] != "+"
      to = "+" + to
    end

    tropo = Tropo::Generator.new do
      call({ :from => from,
      :to => from,
      :network => 'PSTN',
      :channel => 'VOICE' })
      say 'connecting your call!'
      transfer({ :to => to })
    end
    
    tropo
  end
  
  private

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
    number_to_search = ""
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

end
