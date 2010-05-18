class ProfilesController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]

  def index
    
    usercount = 0
    
    # Execute at Login - TODO: Move to method
    current_user = AppEngine::Users.current_user
    if current_user
      user = User.find_by_email(current_user.email)
      if user
        # user.attributes = {
        #   :email => current_user.email,
        #   :nickname => current_user.nickname,
        #   :updated_at => Time.now()
        # }
        # user.save

        session[:current_user_id] = user.id
        usercount = 1
        
      else
        
        usercount = User.all
        
        if usercount.length == 0
          
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
          usercount = 1
          
        end

      end
      
    end
    
    
    if usercount == 1
      session[:nickname] = current_user.nickname
      session[:email] = current_user.email
      session[:apikey] = user.apikey

      # @profiles = Profile.all
      @profiles = Profile.first(:user_id => session[:current_user_id]) 
      @call_screening = @profiles.call_screening rescue false
    
      if !@profiles
        redirect_to('/profiles/new')
      else
        respond_to do |format|
          format.html
          format.xml  { render :xml => @profiles }
        end      
      end
    
    else
      logout_url = AppEngine::Users.create_logout_url('/logout') 
      redirect_to(logout_url)
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
      :greeting_name => params[:profile][:greeting_name],
      :voice => params[:profile][:voice],
      :skype => params[:profile][:skype],
      :sip => params[:profile][:sip],
      :inum => params[:profile][:inum],
      :tropo => params[:profile][:tropo],
      :twitter => params[:profile][:twitter],
      :gtalk => params[:profile][:gtalk],
      :voice_token => params[:profile][:voice_token],
      :sms_token => params[:profile][:sms_token],
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

  def map
    render :layout => false
  end

  def social
    
    socialid = params[:id].split(":")
    @twitter = socialid[0] 
    @gtalk = socialid[1]
    
    if @twitter != "!"
      resp = AppEngine::URLFetch.fetch("http://socialgraph.apis.google.com/lookup?q=http%3A%2F%2Ftwitter.com%2F" + @twitter + "&fme=1&pretty=1&callback=",
        :method => :get,
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded'}) rescue ""
    
      @result = JSON.parse(resp.body) rescue ""
      @photo = @result['nodes']['http://twitter.com/' + @twitter]['attributes']['photo'] rescue ""
      @name = @result['nodes']['http://twitter.com/' + @twitter]['attributes']['fn'] rescue ""
      @address = @result['nodes']['http://twitter.com/' + @twitter]['attributes']['adr'] rescue ""
      @rss = @result['nodes']['http://twitter.com/' + @twitter]['attributes']['rss'] rescue ""
      @web1 = @result['nodes']['http://twitter.com/' + @twitter]['claimed_nodes'][0] rescue ""
      @web2 = @result['nodes']['http://twitter.com/' + @twitter]['claimed_nodes'][1] rescue ""
      @web3 = @result['nodes']['http://twitter.com/' + @twitter]['claimed_nodes'][2] rescue ""
    
      resp2 = AppEngine::URLFetch.fetch("http://twitter.com/statuses/user_timeline/" + @twitter + ".json",
        :method => :get,
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded'}) rescue ""
    
      @result2 = JSON.parse(resp2.body) rescue ""
      @twitter1 = @result2[0]['text'] rescue ""
      @twitter2 = @result2[1]['text'] rescue ""
      @twitter3 = @result2[2]['text'] rescue ""
    end

    if @gtalk != "!"
      
      url = "http://www.poweringnews.com/feed-to-json.aspx?feedurl=http%3A//buzz.googleapis.com/feeds/" + @gtalk + "/public/posted"
      
      
      resp = AppEngine::URLFetch.fetch(url,
        :method => :get,
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded'}) rescue ""

      # feed_url = URI.encode("http://buzz.googleapis.com/feeds/" + @gtalk + "/public/posted")
      # 
      # form_fields = {
      #   "feed": feed_url
      # }
      # form_data = urllib.urlencode(form_fields)
      # 
      # 
      # resp = AppEngine::URLFetch.fetch("http://lukemorton.co.uk/feed-parser/",
      #   :method => :post,
      #   :payload => form_data,
      #   :headers => {'Content-Type' => 'application/x-www-form-urlencoded'}) rescue ""

    
      @result3 = JSON.parse(resp.body) rescue ""
# puts "gtalk:" + @result3.to_s
      # @buzz1 = @result3['feed']['entry'][0]['activity:object']['content']['value'] rescue ""
      @buzz1 = @result3['feed']['entry'][0]['activity:object'][0]['content'][0]['value'].to_s rescue ""
      @buzz2 = @result3['feed']['entry'][1]['activity:object'][0]['content'][0]['value'].to_s rescue ""
      @buzz3 = @result3['feed']['entry'][2]['activity:object'][0]['content'][0]['value'].to_s rescue ""
      
      # puts ">>" + @result3['feed']['entry'][0]['activity:object'][0]['content'][0]['value'].to_s
      # puts ">>" + @result3['feed']['entry'][1]['activity:object'][0]['content'][0]['value'].to_s
    end
    
    render :layout => false
  end
  
  def logout
    session[:current_user_id] = nil
    session[:nickname] = nil
    session[:apikey] = nil
    redirect_to('/')
  end
  
  def widget
    # user = User.find_by_apikey(params[:apikey])
    user = User.first(:apikey => params[:apikey])
    if user
      @apikey = params[:apikey]
    else 
      @apikey = nil
    end
    render :layout => false
  end
  
  def update_checkbox
    current_user = session[:current_user_id]
    @profile = Profile.first(:user_id => current_user)
        
    # @call_screening = '1' == params[:call_screening]
    
    # @profile.call_screening = @call_screening

    if @profile.call_screening == true
      @profile.call_screening = false
      
    else
      @profile.call_screening = true
    end  
    @profile.save
    
    render :update do |page|
      page.alert "Call Screening:  #{@profile.call_screening}"
    end
  end
  
end
