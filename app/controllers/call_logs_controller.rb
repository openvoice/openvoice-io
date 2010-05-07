class CallLogsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
  def index
    if session[:current_user_id]
      current_user = session[:current_user_id]
    else
      user = User.find_by_apikey(params[:apikey])
      if user
        current_user = user.id
      end
    end    
    
    @call_logs = CallLog.all(:user_id => current_user, :order => [ :created_at.desc ]).limit_page params[:page], :limit => 10

    respond_to do |format|
      format.html
      format.xml  { render :xml => @call_logs }
      format.json  { render :json => @call_logs }
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
    
    @call_log = CallLog.find(params[:id])
    
    respond_to do |format|
      if @call_log and @call_log.user_id == current_user
        format.html
        format.xml  { render :xml => @call_log }
        format.json  { render :json => @call_log }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/call_logs') }
        format.xml  { render :xml => '<status>failure</status>', :status => :unprocessable_entity }
        format.json { render :json => '{"status":{"value":"failure"}}' }
      end
    end
    
  end

  def new
    @call_log = CallLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @call_log }
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

    if current_user 
    
      @call_log = CallLog.new
      @call_log.attributes = {
        :to => params[:call_log][:to],
        :from => params[:call_log][:from],
        :nature => params[:call_log][:nature],
        :user_id => current_user,
        :created_at => Time.now()
      }
    
      # @call_log = CallLog.new(params[:call_log])

      respond_to do |format|
        if @call_log.save
          flash[:notice] = 'CallLog was successfully created.'
          format.html { redirect_to(@call_log) }
          format.xml  { render :xml => @call_log, :status => :created, :location => @call_log }
          format.json  { render :json => @call_log, :status => :created, :location => @call_log }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @call_log.errors, :status => :unprocessable_entity }
          format.json  { render :json => @call_log.errors, :status => :unprocessable_entity }
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
    
    @call_log = CallLog.find(params[:id])
    
    respond_to do |format|
      if @call_log.user_id == current_user
        if @call_log.update_attributes(params[:call_log])
          flash[:notice] = 'Call Log was successfully updated.'
          format.html { redirect_to('/call_logs') }
          format.xml  { head :ok }
          format.json  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @call_log.errors, :status => :unprocessable_entity }
          format.json  { render :xml => @call_log.errors, :status => :unprocessable_entity }
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
    
    @call_log = CallLog.find(params[:id])
    
    respond_to do |format|
      if call_log.user_id == current_user
        call_log.destroy
        flash[:notice] = 'Call Log was successfully deleted.'
        format.html { redirect_to('/call_logs') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:warning] = 'Access denied.'
        format.html { redirect_to('/call_logs') }
        format.xml  { render :xml => contact.errors, :status => :unprocessable_entity }
        format.json { render :json => contact.errors, :status => :unprocessable_entity }
      end
    end
    
  end
end
