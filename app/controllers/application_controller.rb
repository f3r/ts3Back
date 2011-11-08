include GeneralHelper
class ApplicationController < ActionController::Base
  rescue_from Exceptions::UnauthorizedAccess, :with => :unauthorized_access
  rescue_from Exceptions::NotActivated, :with => :not_activated
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :not_found
  rescue_from ActionController::UnknownAction, :with => :not_found

  protect_from_forgery

  def current_user
    warden.user || User.find_for_token_authentication(:auth_token => params[:access_token])
  end
  
  def check_token
    if params[:access_token]
      user = User.find_for_token_authentication(:auth_token => params[:access_token])
      raise Exceptions::NotActivated if user && !user.activated?
      raise Exceptions::UnauthorizedAccess if !user
    else
      raise Exceptions::UnauthorizedAccess
    end
  end
  
  # Status = HTTP Status code (ie. 200)
  # Stat   = Message status code (ie. :ok or :fail)
  # Fields = Array of key/value fields passed in the message
  #          {:err => {:availabilities => [115]} }
  def return_message(status,stat,fields={})
    response = {}
    response.merge!(:stat => stat)
    response.merge!(fields)
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => status, 
        request.format.to_sym => format_response(response, request.format.to_sym)
      }
    end
  end
  
  private

  def unauthorized_access
    return_message(401,:fail,{:err => {:access_token => [105]}})
  end

  def not_activated
    return_message(401,:fail,{:err => {:user => [130]}})
  end

  def not_found
    return_message(404,:fail,{:err => {:record => [106]}})
  end

end