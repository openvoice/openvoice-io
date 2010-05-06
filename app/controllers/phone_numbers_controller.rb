class PhoneNumbersController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  def index
    if session[:current_user_id]
      current_user = session[:current_user_id]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end    
    
    @phone_numbers = PhoneNumber.all(:user_id => current_user)
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @phone_numbers }
      format.json  { render :json => @phone_numbers }
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
    
    @phone_number = PhoneNumber.find(params[:id])
    
    respond_to do |format|
      if @phone_number and @phone_number.user_id == current_user
        format.html
        format.xml  { render :xml => @phone_number }
        format.json  { render :json => @phone_number }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/phone_numbers') }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
    end
    
  end

  def new
    @phone_number = PhoneNumber.new
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @phone_number }
    end
  end

  def edit
    current_user = session[:current_user_id]
    @user = current_user
    @phone_number = PhoneNumber.find(params[:id])
  end

  def create
    
    if session[:current_user_id]
      current_user = session[:current_user_id]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end

    if current_user
      @phone_number = PhoneNumber.new
      @phone_number.attributes = {
        :number => params[:phone_number][:number],
        :description => params[:phone_number][:description],
        :forward => params[:phone_number][:forward],
        :user_id => current_user,
        :created_at => Time.now()
      }
    
    
      respond_to do |format|
        if @phone_number.save
          flash[:notice] = 'PhoneNumber was successfully created.'
          format.html { redirect_to(phone_numbers_path) }
          format.xml  { render :xml => @phone_number, :status => :created, :location => @phone_number }
          format.json  { render :json => @phone_number, :status => :created, :location => @phone_number }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
          format.json  { render :json => @phone_number.errors, :status => :unprocessable_entity }
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
    
    @phone_number = PhoneNumber.find(params[:id])
    
    respond_to do |format|
      if @phone_number.user_id == current_user
        if @phone_number.update_attributes(params[:phone_number])
          flash[:notice] = 'Phone Number was successfully updated.'
          format.html { redirect_to('/phone_numbers') }
          format.xml  { head :ok }
          format.json  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
          format.json  { render :json => @phone_number.errors, :status => :unprocessable_entity }
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

    @phone_number = PhoneNumber.find(params[:id])
    
    respond_to do |format|
      if phone_number.user_id == current_user
        phone_number.destroy
        flash[:notice] = 'Phone Number was successfully deleted.'
        format.html { redirect_to('/phone_numbers') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/phone_numbers') }
        format.xml  { render :xml => contact.errors, :status => :unprocessable_entity }
        format.json { render :json => contact.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def locate_user
    # phone_number = PhoneNumber.find_by_number(params[:phone_number])
    phone_number = PhoneNumber.all(:number => params[:phone_number])
    if phone_number
      # user = phone_number.user
      user = User.all(:id => phone_number.user_id)
      if user
        render :json => user
      end
    end
  end

end
