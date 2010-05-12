# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  require 'appengine-apis/users'
  require 'cgi'
  require 'json'
  require 'dm-core'
  require 'dm-serializer'
  require 'will_paginate'
  require 'gdata'
  # require 'openssl'

  # GOOGLE DOCS AND CONTACTS DATA API
  DOCLIST_SCOPE = 'http://docs.google.com/feeds/'
  DOCLIST_DOWNLOD_SCOPE = 'http://docs.googleusercontent.com/'
  CONTACTS_SCOPE = 'http://www.google.com/m8/feeds/'
  SPREADSHEETS_SCOPE = 'http://spreadsheets.google.com/feeds/'

  DOCLIST_FEED = DOCLIST_SCOPE + 'default/private/full'

  DOCUMENT_DOC_TYPE = 'document'
  FOLDER_DOC_TYPE = 'folder'
  PRESO_DOC_TYPE = 'presentation'
  PDF_DOC_TYPE = 'pdf'
  SPREADSHEET_DOC_TYPE = 'spreadsheet'
  MINE_LABEL = 'mine'
  STARRED_LABEL = 'starred'
  TRASHED_LABEL = 'trashed'

  MAX_CONTACTS_RESULTS = 500

  private

  def setup_client
    # scopes = [DOCLIST_SCOPE, DOCLIST_DOWNLOD_SCOPE,
    #           SPREADSHEETS_SCOPE, CONTACTS_SCOPE]
    scopes = [CONTACTS_SCOPE]
    @client = GData::Client::DocList.new({:authsub_scope => scopes.join(' '),
                                          :source => 'google-DocListManager-v1.1',
                                          :version => '3.0'})

    if params[:token].nil? and session[:token].nil?
      next_url = url_for :controller => self.controller_name, :action => self.action_name
      secure = false
      @authsub_link = @client.authsub_url(next_url, secure, true)
      # render :controller => 'contacts', :action => 'index'
      redirect_to :controller => 'contacts', :action => 'index'
    elsif params[:token] and session[:token].nil?
      @client.authsub_token = params[:token]
      session[:token] = @client.auth_handler.upgrade()
    end

    @client.authsub_token = session[:token] if session[:token]
  end

  
end
