class SysConfigsController < ApplicationController
  # GET /sys_configs
  # GET /sys_configs.xml
  def index
    @sys_configs = SysConfig.all
    
    if @sys_configs.length > 0
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @sys_configs }
      end
    else
      redirect_to :action=> 'new'
    end
  end

  # GET /sys_configs/1
  # GET /sys_configs/1.xml
  def show
    @sys_config = SysConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sys_config }
    end
  end

  # GET /sys_configs/new
  # GET /sys_configs/new.xml
  def new
    @sys_config = SysConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sys_config }
    end
  end

  # GET /sys_configs/1/edit
  def edit
    @sys_config = SysConfig.find(params[:id])
  end

  # POST /sys_configs
  # POST /sys_configs.xml
  def create
    @sys_config = SysConfig.new(params[:sys_config])

    respond_to do |format|
      if @sys_config.save
        flash[:notice] = 'SysConfig was successfully created.'
        format.html { redirect_to(sys_configs_path) }
        format.xml  { render :xml => @sys_config, :status => :created, :location => @sys_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sys_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sys_configs/1
  # PUT /sys_configs/1.xml
  def update
    @sys_config = SysConfig.find(params[:id])

    respond_to do |format|
      if @sys_config.update_attributes(params[:sys_config])
        flash[:notice] = 'SysConfig was successfully updated.'
        format.html { redirect_to(@sys_config) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sys_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sys_configs/1
  # DELETE /sys_configs/1.xml
  def destroy
    @sys_config = SysConfig.find(params[:id])
    @sys_config.destroy

    respond_to do |format|
      format.html { redirect_to(sys_configs_url) }
      format.xml  { head :ok }
    end
  end
end
