class VoicemailsController < ApplicationController
  # before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
  def index
    @voicemails = Voicemail.all(:user_id => session[:current_user_id], :order => [ :created_at.desc ]) 
    # @voicemails = Voicemail.all
    
    # @voicemails = current_user.voicemails.reverse

    respond_to do |format|
      format.html
      format.xml  { render :xml => @voicemails }
      format.json  { render :json => @voicemails }
    end
  end

  def show
    @voicemail = Voicemail.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @voicemail }
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
    # require "aws/s3"
    # 
    # #TODO - validate
    # AWS::S3::Base.establish_connection!(
    #         :access_key_id     => 'AKIAJL7N4ODM3NMNTFCA',
    #         :secret_access_key => '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'
    # )
    # 
    # original_filename = params[:filename].original_filename
    # 
    # AWS::S3::S3Object.store(original_filename,
    #                         params[:filename],
    #                         'voicemails-dev.tropovoice.com',
    #                         :access => :public_read)
    # 
    # path = 'http://voicemails-dev.tropovoice.com' + '.s3.amazonaws.com/' + original_filename

    # @voicemail = Voicemail.new(:filename => path, :user_id => User.find(1), :from => params[:caller_id])
    
    require 'appengine-apis/images'
    
    
    voicemail = Voicemail.new
    voicemail.attributes = {
      :data => AppEngine::Images.load(params[:filename].read),
      :from => params[:caller_id],
      :user_id => params[:user_id],
      :created_at => Time.now()
    }
    # image =  AppEngine::Images.load(params[:img][:tempfile].read)
    # file = ImageFile.new({})
    # file.data = image.resize(100,100).data
    # if file.save

    
    
    
#    respond_to do |format|
    if voicemail.save
      
      # require 'appengine-apis/datastore'
      # 
      # # e = AppEngine::Datastore::Entity.new('Message')
      # # # e[:id] = voicemail.id
      # # e[:vmail] = params[:filename].read
      # 
      # e = AppEngine::Datastore::Blob.new('Message')
      # # e[:id] = voicemail.id
      # e[:vmail] = params[:filename].read
      # 
      # 
      # AppEngine::Datastore.put e
      
      
      flash[:notice] = 'Voicemail was successfully created.'
#        format.html { redirect_to(@voicemail) }
#        format.xml  { render :xml => @voicemail, :status => :created, :location => @voicemail }
    else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @voicemail.errors, :status => :unprocessable_entity }
    end

    head 200
#    end
  end

  def update
    current_user = session[:current_user_id]
    @voicemail = Voicemail.find(params[:id])

    respond_to do |format|
      if @voicemail.update_attributes(params[:voicemail])
        flash[:notice] = 'Voicemail was successfully updated.'
        format.html { redirect_to('/voicemails') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voicemail.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = session[:current_user_id]
    @voicemail = Voicemail.find(params[:id])
    @voicemail.destroy

    respond_to do |format|
      format.html { redirect_to('/voicemails') }
      format.xml  { head :ok }
    end
  end
  
  def play
    @voicemails = Voicemail.find(params[:id])
    @audio = @voicemails.data
    send_data (@audio, :type => 'mp3', :filename => 'message.mp3', :disposition => 'inline') 
  end

end
