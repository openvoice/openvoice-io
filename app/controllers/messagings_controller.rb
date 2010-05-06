class MessagingsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]

  def index
    # @messagings = current_user.messagings.reverse
    
    if session[:current_user_id]
      #Web Session
      current_user = session[:current_user_id]
    else
      if params[:apikey]
        #API with key
        user = User.find_by_apikey(params[:apikey])
        if user
          current_user = user.id
        end
        
      else
        #API with Google Basic Auth
        args = {
          'Email'   => params[:email],
          'Passwd'   => params[:password], 
          'source'   => 'Google Auth Base Ruby Gem', 
          'continue' => ''
        }
        
        result = AppEngine::URLFetch.fetch("https://www.google.com:443/accounts/ClientLogin",
          :payload => Rack::Utils.build_query(args),
          :method => :post,
          :headers => {'Content-Type' => 'application/x-www-form-urlencoded'})

        sid = extract_sid(result.body)
        
        if sid
          user = User.find_by_email(params[:email])
           if user
             current_user = user.id
           end
        end
        
      end
    end
    
    @messagings = Messaging.all(:user_id => current_user, :order => [ :created_at.desc ])  

    respond_to do |format|
      format.html
      format.xml  { render :xml => @messagings }
      format.json { render :json => @messagings }
    end
  end
  
  def extract_sid(body)
    matches = body.match(/SID=(.*)/)
    matches.nil? ? nil : matches[0].gsub('SID=', '')
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

    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      if @messaging and @messaging.user_id == current_user
        format.html
        format.xml  { render :xml => @messaging }
        format.json  { render :json => @messaging }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/messagings') }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
    end
  end

  def new
    @messaging = Messaging.new
    @messaging.to = params[:to] unless params[:to].nil?
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @messaging }
    end
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
    
    
    from = to = ""
    # if session = params[:session]
    # if params[:session] # TODO - Validate
      
    if current_user  
      
      session = params[:session]
      if session && session[:parameters].nil? && !session[:initialText].nil?

        # then this is a request from tropo, create an incoming message
        from = session[:from][:id]
        text = session[:initialText]
        to = session[:to][:id]
      
        phonenumber = Profile.find_by_voice(to)
      	if phonenumber
      	  firstnumber = phonenumber.number
      	else
          firstnumber = '16025551212'
      	end 
      

        # @user = User.find(current_user)
        # to = @user.login
        # @messaging = Messaging.new(:from => from, :text => text, :to => to, :user_id => @user.id, :outgoing => false)
      
        messaging = Messaging.new
        messaging.attributes = {
          :from => from,
          :to => firstnumber,
          :text => text,
          :user_id => @user.id,
          :outgoing => false,
          :created_at => Time.now()
        }
      
        outgoing = false
      
      else

        if session[:current_user_id]
        
          #Lookup account holder's number
          phonenumber = PhoneNumber.first(:user_id => current_user) 
        	if phonenumber
        	  firstnumber = phonenumber.number
        	else
        	  firstnumber = '16025551212'
        	end
          from = firstnumber
        
          to = params[:messaging][:to]
          text = params[:messaging][:text]
        else
          user = User.find_by_apikey(params[:apikey])
          if user
            current_user = user.id
            from = params[:from]
            to = params[:to]
            text = params[:text]
          end
        end



        user = User.first(:id => current_user)
        messaging = Messaging.new
        messaging.attributes = {
          :from => from,
          :to => to,
          :text => text,
          :user_id => current_user,
          :outgoing => true,
          :created_at => Time.now()
        }


        outgoing = true

      end
    

      respond_to do |format|
        if messaging.save
        
          if outgoing
          
            # tropo = Tropo::Generator.new do
            #   call({ :from => from,
            #          :to => to,
            #          :network => 'SMS',
            #          :channel => 'TEXT' })
            #   say text
            # end
            # 
            # render :json => tropo.response
            # return          

            msg_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_MESSAGING_TEMP + '&from='+ from + '&to=' + to + '&text=' + CGI::escape(text)

            result = AppEngine::URLFetch.fetch(msg_url,
              :method => :get,
              :headers => {'Content-Type' => 'application/x-www-form-urlencoded'})
          end
        
        
          flash[:notice] = 'Message was successfully created.'
          format.html { redirect_to('/messagings') }
          format.xml  { render :xml => '<status>success</status>', :status => :created }
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
  
  def edit
    current_user = session[:current_user_id]
    
    @user = current_user
    @messaging = Messaging.find(params[:id])
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
    
    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      if @messaging.user_id == current_user
        if @messaging.update_attributes(params[:messaging])
          flash[:notice] = 'Message was successfully updated.'
          format.html { redirect_to('/messagings') }
          format.xml  { head :ok }
          format.json  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @messaging.errors, :status => :unprocessable_entity }
          format.json  { render :json => @messaging.errors, :status => :unprocessable_entity }
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
    
    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      if @messaging.user_id == current_user
        @messaging.destroy
        flash[:notice] = 'Message was successfully deleted.'
        format.html { redirect_to('/messagings') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/messagings') }
        format.xml  { render :xml => @messaging.errors, :status => :unprocessable_entity }
        format.json { render :json => @messaging.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  
end
