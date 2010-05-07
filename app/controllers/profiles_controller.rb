class ProfilesController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def index
    
    # Execute at Login - TODO: Move to method
    current_user = AppEngine::Users.current_user
    if current_user
      user = User.find_by_email(current_user.email)
      if user
        user.attributes = {
          :email => current_user.email,
          :nickname => current_user.nickname,
          :updated_at => Time.now()
        }
        user.save

        session[:current_user_id] = user.id
        
      else
        
        # Generate API Key
        require 'sha1'
        srand
        seed = "--#{rand(10000)}--#{Time.now}--"
        apikey = Digest::SHA1.hexdigest(seed)
        
        user = User.new
        user.attributes = {
          :email => current_user.email,
          :nickname => current_user.nickname,
          :apikey => apikey,
          :created_at => Time.now()
        }
        user.save
        session[:current_user_id] = user.id
      end
      session[:nickname] = current_user.nickname
      session[:email] = current_user.email
      session[:apikey] = user.apikey
      
    end
    
    
    
    # @profiles = Profile.all
    @profiles = Profile.all(:user_id => session[:current_user_id]) 
    
    if @profiles.length == 0
      redirect_to('/profiles/new')
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @profiles }
      end      
    end
  end

  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @profile }
    end
  end

  def new
    @profile = Profile.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @profile }
    end
  end

  def edit
    @profile = Profile.find(params[:id])
  end

  def create
    current_user = session[:current_user_id]
    profile = Profile.new
    profile.attributes = {
      :voice => params[:profile][:voice],
      :skype => params[:profile][:skype],
      :sip => params[:profile][:sip],
      :inum => params[:profile][:inum],
      :tropo => params[:profile][:tropo],
      :twitter => params[:profile][:twitter],
      :gtalk => params[:profile][:gtalk],
      :user_id => current_user,
      :created_at => Time.now()
    }

    
    # @profile = Profile.new(params[:profile].merge(:user_id => params[:user_id]))

    respond_to do |format|
      if profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to(profiles_path) }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    current_user = session[:current_user_id]
    @profile = Profile.find(params[:id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        # format.html { redirect_to(user_profiles_path(current_user)) }
        format.html { redirect_to('/profiles') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = session[:current_user_id]
    
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      # format.html { redirect_to(user_profiles_url(current_user)) }
      format.html { redirect_to('/profiles') }
      format.xml  { head :ok }
    end
  end
  
  def genapikey
    user = User.find(session[:current_user_id])
    if user
      # Generate API Key
      require 'sha1'
      srand
      seed = "--#{rand(10000)}--#{Time.now}--"
      apikey = Digest::SHA1.hexdigest(seed)
      
      user.attributes = {
        :apikey => apikey
      }
      user.save
      session[:apikey] = user.apikey
    end    
    render :action => 'api'
  end
  
  def api
    if session[:current_user_id].nil?
      redirect_to "/"
    end      
  end

  def home
    render :layout => false
  end
  
  def logout
    session[:current_user_id] = nil
    session[:nickname] = nil
    session[:apikey] = nil
    redirect_to('/')
  end
  
  def widget
    user = User.find_by_apikey(params[:apikey])
    if user
      @apikey = params[:apikey]
    else 
      @apikey = nil
    end
    render :layout => false
  end
  
end
