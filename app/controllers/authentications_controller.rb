class AuthenticationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
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
    @authentications = current_user.authentications
    respond_with do |format|
      if @authentications
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :authentications => @authentications },
            request.format.to_sym) }
      end
    end
  end

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

  # ==Resource URL
  # /users/facebook/info.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/facebook/info.json access_token=access_token
  # === Parameters
  # [:access_token] User access token
  # [:image_size]   Optional image size. Accepted values: small, normal, large
  # === Response
  # [:user_info] Array containing the users information and picture url
  # === Error codes
  # [105] Invalid access token
  # [111] Invalid oauth request
  # [112] This user doesn't have a linked Facebook account
  #
  # TODO: Move api keys to settings file
  def get_facebook_info
    check_token
    respond_with do |format|
      begin
        authentication = current_user.authentications.where(:provider => "facebook").first
        if authentication
          client = OAuth2::Client.new("221413484589066", "719daf903365b4bab445a2ef5c54c2ea", :site => 'https://graph.facebook.com')
          facebook = OAuth2::AccessToken.new(client, authentication.token)
          info = JSON.parse(facebook.get("/#{authentication.uid}"))
          birthday = Date.strptime(info['birthday'], "%m/%d/%Y")
          image_size = params[:image_size].blank? ? "large" : params[:image_size]
          @info = {
            :name => info['name'],
            :gender => info['gender'],
            :birthday => birthday,
            :picture => "http://graph.facebook.com/" + info['id'] + "/picture?type=#{image_size}"
          }
        end
        if @info
          format.any(:xml, :json) { 
            render :status => 200, 
            request.format.to_sym => format_response({ 
              :stat => "ok", :user_info => @info },
              request.format.to_sym) }
        else
          format.any(:xml, :json) { 
            render :status => 200, 
            request.format.to_sym => format_response({ 
              :stat => "fail", 
              :err => {:user => [112]}},
              request.format.to_sym) }
        end
      rescue Exception => e
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => {:oauth => [111], :msg => e} },
            request.format.to_sym) }
      end
    end
  end
end