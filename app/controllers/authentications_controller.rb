class AuthenticationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  def initialize
    @fields = [:id, :provider, :uid]
  end

  # == Description
  # Adds an authentication method to the current_user
  # ==Resource URL
  # /authentications.format
  # ==Example
  # POST https://backend-heypal.heroku.com/authentications.json access_token=access_token&oauth_token=oauth_token
  # === Parameters
  # [:access_token] Access token
  # [:oauth_token] oauth token
  # === Response
  # [:authentication] id, provider, uid  
  # === Error codes
  # [117] Invalid oauth token
  # [100] has already been taken
  def create
    check_token
    if params[:oauth_token] && params[:oauth_token]['credentials']
      authentication = current_user.authentications.new(
        :provider => params[:oauth_token]['provider'], 
        :uid      => params[:oauth_token]['uid'], 
        :token    => params[:oauth_token]['credentials']['token'], 
        :secret   => params[:oauth_token]['credentials']['secret'])
    end
    respond_with do |format|
      if authentication && authentication.save
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok",
            :authentication => filter_fields(authentication,@fields) },
            request.format.to_sym) }
      elsif authentication
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail",
            :err => format_errors(authentication.errors.messages) },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail",
            :err => {:oauth_token=>[117]} },
            request.format.to_sym) }
      end
    end
  end

  # == Description
  # Returns a list of all the authentications of the current_user
  # ==Resource URL
  # /authentications.format
  # ==Example
  # GET https://backend-heypal.heroku.com/authentications.json access_token=access_token
  # === Parameters
  # [:access_token] Access token
  # === Response
  # [:authentications] Array containing a list authentications for the selected user
  def list
    check_token
    @authentications = current_user.authentications.select(@fields)
    respond_with do |format|
      if @authentications
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :authentications => filter_fields(@authentications,@fields) },
            request.format.to_sym) }
      end
    end
  end

  # == Description
  # Deletes one of the authentications of the current user
  # ==Resource URL
  # /authentications/:authentication_id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/authentications/1.json access_token=access_token
  # === Parameters
  # [:access_token] Access token
  # [:authentication_id] Id number of the authentication to be deleted
  # === Error codes
  # [106] Record not found
  def delete
    check_token
    authentication = current_user.authentications.find(params[:authentication_id])
    respond_with do |format|
      if authentication.destroy
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok" },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail",
            :err => format_errors(authentication.errors.messages) },
            request.format.to_sym) }
      end
    end
  end

  # == Description
  # Returns all the info from the facebook profile of the current user
  # including name, gender, birthday and picture_url
  # ==Resource URL
  # /users/facebook/info.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/facebook/info.json access_token=access_token
  # === Parameters
  # [:access_token] User access token
  # [:auto_import] boolean value, if true, it will auto import the facebook information into the user
  # === Response
  # [:user_info] Array containing the users information and picture url
  # === Error codes
  # [105] Invalid access token
  # [111] Invalid oauth request
  # [112] This user doesn't have a linked Facebook account
  def get_facebook_oauth_info
    check_token
    auto_import = true if params[:auto_import] == "1"
    user_info = current_user.facebook_info(auto_import)
    respond_with do |format|
      if user_info
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", :user_info => user_info },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => {:user => [112]}},
            request.format.to_sym) }
      end
    end
  end
end