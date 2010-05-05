class ContactsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def index        
    
    # @contacts = current_user.contacts
    # @contacts = Contact.all
    # @contacts = Contact.find_by_user_id(session[:current_user_id])
    
    if session[:current_user_id]
      current_user = session[:current_user_id]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end
    
    
    @contacts = Contact.all(:user_id => current_user)
    

    respond_to do |format|
      format.html
      format.xml  { render :xml => @contacts }
      format.json  { render :json => @contacts }
    end
  end

  def show
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @contact }
    end
  end

  def new
    @contact = Contact.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @contact }
    end
  end

  def edit
    current_user = session[:current_user_id]
    @user = current_user
    @contact = Contact.find(params[:id])
  end

  def create
    current_user = session[:current_user_id]
    contact = Contact.new
    contact.attributes = {
      :contactname => params[:contact][:contactname],
      :number => params[:contact][:number],
      :im => params[:contact][:im],
      :user_id => current_user,
      :created_at => Time.now()
    }

    respond_to do |format|
      if contact.save
        flash[:notice] = 'Contact was successfully created.'
        format.html { redirect_to(contacts_path) }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    current_user = session[:current_user_id]
    @contact = Contact.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        flash[:notice] = 'Contact was successfully updated.'
        # format.html { redirect_to(@contact) }
        format.html { redirect_to('/contacts') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = session[:current_user_id]
    contact = Contact.find(params[:id])
    contact.destroy

    respond_to do |format|
      # format.html { redirect_to(contacts_url) }
      format.html { redirect_to('/contacts') }
      format.xml  { head :ok }
    end
  end
end
