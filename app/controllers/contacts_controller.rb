class ContactsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
  
  # before_filter :setup_client #Google Data
  CONTACTS_FEED = CONTACTS_SCOPE + 'contacts/default/full/'

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
    
    # @contacts = Contact.all(:user_id => current_user).limit_page params[:page], :limit => 10
    # @contacts = Contact.all(:user_id => current_user)
    @contacts = user.contacts.paginate :page => params[:page], :order => [ :contactname.asc ]

    respond_to do |format|
      format.html
      format.xml  { render :xml => @contacts }
      format.json  { render :json => @contacts }
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
    
    @contact = Contact.find(params[:id])
    
    respond_to do |format|
      if @contact and @contact.user_id == current_user
        format.html
        format.xml  { render :xml => @contact }
        format.json  { render :json => @contact }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/contacts') }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
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
    
    if session[:current_user_id]
      current_user = session[:current_user_id]
      user = User.find(current_user)      
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end

    if current_user 
      @contact = Contact.new
      @contact.attributes = {
        :contactname => params[:contact][:contactname],
        :number => params[:contact][:number],
        :sip => params[:contact][:sip],
        :inum => params[:contact][:inum],
        :im => params[:contact][:im],
        :twitter => params[:contact][:twitter],
        :gtalk => params[:contact][:gtalk],
        :user_id => current_user,
        :created_at => Time.now()
      }

      respond_to do |format|
        if @contact.save
          flash[:notice] = 'Contact was successfully created.'
          format.html { redirect_to(contacts_path) }
          format.xml  { render :xml => @contact, :status => :created, :location => @contact }
          format.json  { render :json => @contact, :status => :created, :location => @contact }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
          format.json  { render :json => @contact.errors, :status => :unprocessable_entity }
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
    
    @contact = Contact.find(params[:id])
    
    respond_to do |format|
      if @contact.user_id == current_user
        if @contact.update_attributes(params[:contact])
          flash[:notice] = 'Contact was successfully updated.'
          format.html { redirect_to('/contacts') }
          format.xml  { head :ok }
          format.json  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
          format.json  { render :xml => @contact.errors, :status => :unprocessable_entity }
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

    contact = Contact.find(params[:id])
    
    respond_to do |format|
      if contact.user_id == current_user
        contact.destroy
        flash[:notice] = 'Contact was successfully deleted.'
        format.html { redirect_to('/contacts') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/contacts') }
        format.xml  { render :xml => contact.errors, :status => :unprocessable_entity }
        format.json { render :json => contact.errors, :status => :unprocessable_entity }
      end
    end    
    
  end
  
  def gmailcontacts
    setup_client
    # if !request.xhr?
    #   redirect_to :controller => 'profiles', :action => 'index' and return
    # end
    
    groups_feed = @client.get(CONTACTS_SCOPE + 'groups/default/full/').to_xml
    # begin
    #   groups_feed = AppEngine::URLFetch.fetch(CONTACTS_SCOPE + 'groups/default/full/', :method => :get, :deadline => 10).to_xml
    # rescue Exception=>e
    #   logger.error e
    # end
    
    group_id = my_contacts_group_id(groups_feed)
    url = CONTACTS_FEED +
          "?group=#{group_id}&max-results=#{MAX_CONTACTS_RESULTS.to_s}"
    feed = @client.get(url).to_xml
    # begin
    #   feed = AppEngine::URLFetch.fetch(url, :method => :get, :deadline => 10).to_xml
    # rescue Exception=>e
    #   logger.error e
    # end
    
    session[:users_email] = feed.elements['id'].text if !session[:users_email]
    
    @contacts = []
    feed.elements.each('entry') do |entry|
      contact = GContact::Contact.new(entry.elements['title'].text, nil,
                                      entry.to_s)
      entry.elements.each('gd:email') do |email|
        if email.attribute('primary')
          contact.email = email.attribute('address').value
        end
      end
      @contacts.push(contact)
    end
    @acl_feedlink = params[:acl_feedlink]
    # render :action => 'all'
  end
  

  private

    def my_contacts_group_id(feed)
      feed.elements.each('entry') do |entry|
        entry.each_element_with_attribute('id', 'Contacts', 0,
                                          'gContact:systemGroup') do |e|
          return e.parent.elements['id'].text
        end
      end
    end

end
