class AuthenticationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  
  # ==Resource URL
  # /users/authentications/list.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/authentications/list.json access_token=access_token
  # === Parameters
  # [:access_token]
  #   Access token
  # === Response
  # [:authentications]
  #   Array containing a list authentications for the selected user
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
  # /users/authentications/:authentication_id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/users/authentications/1.json access_token=access_token
  # === Parameters
  # [:access_token]
  #   Access token
  # [:authentication_id]
  #   Id number of the authentication to be deleted
  # === Error codes
  # [106]
  #   Record not found
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
  
end