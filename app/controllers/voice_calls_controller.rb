class VoiceCallsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  def index
    current_user = AppEngine::Users.current_user
    
    # @voice_calls = current_user.voice_calls.reverse
# p current_user
# p @voice_calls

    @voice_calls = VoiceCall.all(:user_id => session[:current_user_id]) #TODO reverse order

    
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

    current_user = params[:user_id]
    voice_call = VoiceCall.new
    voice_call.attributes = {
      :to => params[:voice_call][:to],
      :user_id => current_user,
      :created_at => Time.now()
    }


    respond_to do |format|
      if voice_call.save
        
        #     call_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_VOICE_TEMP + '&to=' + to + '&from=' + user.phone_numbers.first.number
        #                 # TODO probably change into a primary number, mostly likely a pstn number
        # 
        # 
        #     open(call_url) do |r|
        #       p r
        #     end
        
        phonenumber = PhoneNumber.first(:user_id => current_user) 
      	if phonenumber
      	  firstnumber = phonenumber.number
      	else
      	  firstnumber = '6025551212'
      	end 
      	
        
        args = {
          'action'  => 'create',
          'token'   => OUTBOUND_VOICE_TEMP, 
          'to'      => params[:voice_call][:to],
          'from'    => firstnumber
        }

        result = AppEngine::URLFetch.fetch('http://api.tropo.com/1.0/sessions',
          :payload => Rack::Utils.build_query(args),
          :method => :post,
          :headers => {'Content-Type' => 'application/x-www-form-urlencoded'})

        
        
        flash[:notice] = 'VoiceCall was successfully created.'
        format.html { redirect_to(user_voice_calls_path(current_user)) }
        format.xml  { render :xml => @voice_call, :status => :created, :location => @voice_call }
        format.json { render :json => @voice_call }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    current_user = params[:user_id]
    @voice_call = VoiceCall.find(params[:id])

    respond_to do |format|
      if @voice_call.update_attributes(params[:voice_call])
        flash[:notice] = 'VoiceCall was successfully updated.'
        format.html { redirect_to('/users/' + current_user.to_s + '/voice_calls') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = params[:user_id]
    @voice_call = VoiceCall.find(params[:id])
    @voice_call.destroy

    respond_to do |format|
      format.html { redirect_to('/users/' + current_user.to_s + '/voice_calls') }
      format.xml  { head :ok }
    end
  end
end
