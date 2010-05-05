class VoiceCallsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  def index
    current_user = AppEngine::Users.current_user
    
    # @voice_calls = current_user.voice_calls.reverse
# p current_user
# p @voice_calls

    @voice_calls = VoiceCall.all(:user_id => session[:current_user_id], :order => [ :created_at.desc ]) 

    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @voice_calls }
    end
  end

  def show
    @voice_call = VoiceCall.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voice_call }
    end
  end

  def new
    @voice_call = VoiceCall.new
    @voice_call.to = params[:to] unless params[:to].nil?
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voice_call }
    end
  end

  def create
    # @voice_call = VoiceCall.new(params[:voice_call].merge(:user_id => params[:user_id]))
    
    if session[:current_user_id]
      current_user = session[:current_user_id]
      callto = params[:voice_call][:to]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
        callto = params[:to]
      end
    end
    
    # if callto[0..0] != "+"
    #   callto = "+" + callto
    # end
    
    voice_call = VoiceCall.new
    voice_call.attributes = {
      :to => callto,
      :user_id => current_user,
      :created_at => Time.now()
    }


    respond_to do |format|
      if voice_call.save
                
        #Place Tropo Phone Call         
        phonenumber = PhoneNumber.first(:user_id => current_user) 
      	if phonenumber
      	  firstnumber = phonenumber.number
          # if firstnumber[0..0] != "+"
          #   firstnumber = "+" + firstnumber
          # end
      	else
          # firstnumber = '+16025551212'
          firstnumber = '16025551212'
      	end 
        
        call_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_VOICE_TEMP + '&to=' + callto + '&from=' + firstnumber + '&ov_action=call&user_id=' + current_user.to_s

        result = AppEngine::URLFetch.fetch(call_url,
          :method => :get,
          :headers => {'Content-Type' => 'application/x-www-form-urlencoded'})

        flash[:notice] = 'VoiceCall was successfully created.'
        format.html { redirect_to(voice_calls_path) }
        format.xml  { render :xml => '<status>success</status>', :status => :created }        
        format.json { render :json => '{"status":{"value":"success"}}' }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
    end
  end

  def update
    current_user = session[:current_user_id]
    @voice_call = VoiceCall.find(params[:id])

    respond_to do |format|
      if @voice_call.update_attributes(params[:voice_call])
        flash[:notice] = 'VoiceCall was successfully updated.'
        format.html { redirect_to('/voice_calls') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = session[:current_user_id]
    @voice_call = VoiceCall.find(params[:id])
    @voice_call.destroy

    respond_to do |format|
      format.html { redirect_to('/voice_calls') }
      format.xml  { head :ok }
    end
  end
end
