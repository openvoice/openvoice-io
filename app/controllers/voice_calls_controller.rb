class VoiceCallsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  def index
    # current_user = AppEngine::Users.current_user
    
    if session[:current_user_id]
      current_user = session[:current_user_id]
      user = User.find(current_user)
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end

    # @voice_calls = VoiceCall.all(:user_id => current_user, :order => [ :created_at.desc ]).limit_page params[:page], :limit => 10
    # @voice_calls = VoiceCall.all(:user_id => current_user, :order => [ :created_at.desc ])
    # @voice_calls = user.voice_calls(:order => [ :created_at.desc ])
    # @posts = Post.paginate :page => params[:page], :order => 'updated_at DESC'
    @voice_calls = user.voice_calls.paginate :page => params[:page], :order => [ :created_at.desc ], :per_page => 5
    
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @voice_calls }
      format.json  { render :json => @voice_calls }
    end
  end

  def show
    if session[:current_user_id]
      current_user = session[:current_user_id]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end
    
    @voice_call = VoiceCall.find(params[:id])

    respond_to do |format|
      if @voice_call and @voice_call.user_id == current_user
        format.html
        format.xml  { render :xml => @voice_call }
        format.json  { render :json => @voice_call }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/messagings') }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
      
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
    
    if params[:apikey] 
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
        callto = params[:to]
      end
    else
      current_user = session[:current_user_id]
      callto = params[:voice_call][:to]
    end
    
    # if callto[0..0] != "+"
    #   callto = "+" + callto
    # end
    
    if current_user 
    
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
            # firstnumber = '+14152739939'
            firstnumber = '14152739939'
        	end 
        
          call_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_VOICE_TEMP + '&to=' + callto + '&from=' + firstnumber + '&ov_action=call&user_id=' + current_user.to_s

          result = AppEngine::URLFetch.fetch(call_url,
            :method => :get,
            :headers => {'Content-Type' => 'application/x-www-form-urlencoded'})

          flash[:notice] = 'VoiceCall was successfully created.'
          format.html { redirect_to(voice_calls_path) }
          format.xml  { 
            if params[:source] == "widget"
              render :inline => "Please hold...", :content_type => 'text/plain', :layout => false
            else
              render :xml => '<status>success</status>', :status => :created 
            end
            }        
          format.json { render :json => '{"status":{"value":"success"}}' }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
          format.json { render :json => '{"status":{"value":"failure"}}' }
        end
      end
      
    else
      flash[:warning] = 'Access denied.'
      format.html { render :action => "new" }
      format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
      format.json { render :json => '{"status":{"value":"failure"}}' }
    end

  end

  def update
    if session[:current_user_id]
      current_user = session[:current_user_id]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end

    @voice_call = VoiceCall.find(params[:id])

    respond_to do |format|
      if @voice_call.user_id == current_user
        if @voice_call.update_attributes(params[:voice_call])
          flash[:notice] = 'VoiceCall was successfully updated.'
          format.html { redirect_to('/voice_calls') }
          format.xml  { head :ok }
          format.json  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
          format.json  { render :json => @voice_call.errors, :status => :unprocessable_entity }
        end
      else
        flash[:warning] = 'Access denied.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
    end
  end

  def destroy
    if session[:current_user_id]
      current_user = session[:current_user_id]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end

    @voice_call = VoiceCall.find(params[:id])
    
    respond_to do |format|
      if @voice_call.user_id == current_user
        @voice_call.destroy
        flash[:notice] = 'Message was successfully deleted.'
        format.html { redirect_to('/voice_calls') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/voice_calls') }
        format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
        format.json { render :json => @voice_call.errors, :status => :unprocessable_entity }
      end
    end
    
  end
end
