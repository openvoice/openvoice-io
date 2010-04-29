class ProfilesController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def index
    # @profiles = Profile.all
    @profiles = Profile.all(:user_id => session[:current_user_id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @profiles }
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
    current_user = params[:user_id]
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
        format.html { redirect_to(user_profiles_path(current_user)) }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    current_user = params[:user_id]
    @profile = Profile.find(params[:id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        # format.html { redirect_to(user_profiles_path(current_user)) }
        format.html { redirect_to('/users/' + current_user.to_s + '/profiles') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = params[:user_id]
    
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      # format.html { redirect_to(user_profiles_url(current_user)) }
      format.html { redirect_to('/users/' + current_user.to_s + '/profiles') }
      format.xml  { head :ok }
    end
  end
end
