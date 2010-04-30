class PhoneNumbersController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  def index
    @phone_numbers = PhoneNumber.all(:user_id => session[:current_user_id])
    
    # @user = User.find(params[:user_id])
    # @phone_numbers = @user.phone_numbers

    respond_to do |format|
      format.html
      format.xml  { render :xml => @phone_numbers }
    end
  end

  def show
    @phone_number = PhoneNumber.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @phone_number }
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
    current_user = session[:current_user_id]
    @phone_number = PhoneNumber.new
    @phone_number.attributes = {
      :number => params[:phone_number][:number],
      :description => params[:phone_number][:description],
      :forward => params[:phone_number][:forward],
      :user_id => current_user,
      :created_at => Time.now()
    }
    
    
    # @phone_number = PhoneNumber.new(:number => params[:phone_number][:number],
    #                                 :forward => params[:phone_number][:forward], 
    #                                 :user_id => params[:user_id])

    respond_to do |format|
      if @phone_number.save
        flash[:notice] = 'PhoneNumber was successfully created.'
        format.html { redirect_to(phone_numbers_path) }
        format.xml  { render :xml => @phone_number, :status => :created, :location => @phone_number }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    current_user = session[:current_user_id]
    @phone_number = PhoneNumber.find(params[:id])

    respond_to do |format|
      if @phone_number.update_attributes(params[:phone_number])
        flash[:notice] = 'PhoneNumber was successfully updated.'
        format.html { redirect_to('/phone_numbers') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = session[:current_user_id]
    @phone_number = PhoneNumber.find(params[:id])
    @phone_number.destroy

    respond_to do |format|
      format.html { redirect_to('/phone_numbers') }
      format.xml  { head :ok }
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
