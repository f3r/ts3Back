include GeneralHelper
class ApplicationController < ActionController::Base

  rescue_from Exceptions::UnauthorizedAccess, :with => :unauthorized_access
  rescue_from Exceptions::NotActivated, :with => :not_activated
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :not_found
  rescue_from ::AbstractController::ActionNotFound , :with => :not_found
  rescue_from Authorization::AttributeAuthorizationError, :with => :attribute_authorization_error

  protect_from_forgery


  before_filter :set_current_user

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
      format.html {
        # TODO: Add custom page for html requests
        render :status => 403, :inline => "fail"
      }
    end
  end

  def permission_denied  
    return_message(403,:fail,{:err => {:authorization => [133]}})
  end
  
  protected
  def set_current_user
    Authorization.current_user = current_user
  end
  
  private

  def attribute_authorization_error
    return_message(403,:fail,{:err => {:permissions => [134]}})
  end
  
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