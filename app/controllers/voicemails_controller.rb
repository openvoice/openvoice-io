class VoicemailsController < ApplicationController
  # before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
  def index
    
    if session[:current_user_id]
      current_user = session[:current_user_id]
      user = User.find(current_user)
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end
    
    # @voicemails = Voicemail.all(:user_id => current_user, :order => [ :created_at.desc ]).limit_page params[:page], :limit => 10
    # @voicemails = Voicemail.all(:user_id => current_user, :order => [ :created_at.desc ])
    @voicemails = user.voicemails.paginate :page => params[:page], :order => [ :created_at.desc ]
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @voicemails }
      format.json  { render :json => @voicemails }
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

    @voicemail = Voicemail.find(params[:id])
    
    respond_to do |format|
      if @voicemail and @voicemail.user_id == current_user
        format.html
        format.xml  { render :xml => @voicemail }
        format.json  { render :json => @voicemail }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/voicemails') }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
    end
    
  end

  def new
    @voicemail = Voicemail.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @voicemail }
    end
  end

  def create

    # Method called by Tropo
      
    #API handles binary data to BigTable
    require 'appengine-apis/images'
    
    voicemail = Voicemail.new
    voicemail.attributes = {
      :data => AppEngine::Images.load(params[:filename].read),
      :from => params[:caller_id],
      :user_id => params[:user_id],
      :created_at => Time.now()
    }

    voicemail.save      

    head 200

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
    
    @voicemail = Voicemail.find(params[:id])
    
    respond_to do |format|
      if @voicemail.user_id == current_user
        if @voicemail.update_attributes(params[:voicemail])
          flash[:notice] = 'Voicemail was successfully updated.'
          format.html { redirect_to('/voicemails') }
          format.xml  { head :ok }
          format.json  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @voicemail.errors, :status => :unprocessable_entity }
          format.json  { render :json => @voicemail.errors, :status => :unprocessable_entity }
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

    @voicemail = Voicemail.find(params[:id])
    
    respond_to do |format|
      if @voicemail.user_id == current_user
        @voicemail.destroy
        flash[:notice] = 'Voicemail was successfully deleted.'
        format.html { redirect_to('/voicemails') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/voicemails') }
        format.xml  { render :xml => @voice_call.errors, :status => :unprocessable_entity }
        format.json { render :json => @voice_call.errors, :status => :unprocessable_entity }
      end
    end
    
    
  end
  
  def play
    
    current_user = session[:current_user_id]

    @voicemails = Voicemail.find(params[:id])
    
    if @voicemails.user_id == current_user
      @audio = @voicemails.data
      send_data (@audio, :type => 'mp3', :filename => 'message.mp3', :disposition => 'inline') 
    end
  end

  def set_transcription
    # voicemail = Voicemail.find_by_transcription_id(params[:transcription_id])
    # voicemail.update_attribute("text", params[:transcription])
    # head 200
  end

end
