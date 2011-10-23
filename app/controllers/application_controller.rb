include GeneralHelper
class ApplicationController < ActionController::Base
  rescue_from Exceptions::UnauthorizedAccess, :with => :unauthorized_access
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :not_found
  rescue_from ActionController::UnknownAction, :with => :not_found

  protect_from_forgery

  def authenticated?
    params[:access_token] and User.find_for_token_authentication(:auth_token => params[:access_token])
  end

  def current_user
    warden.user || User.find_for_token_authentication(:auth_token => params[:access_token])
  end
  
  def check_token
    raise Exceptions::UnauthorizedAccess unless authenticated?
  end
  
  private

  def unauthorized_access
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 401, 
        request.format.to_sym => format_response({ 
          :stat => "fail", 
          :err => {:access_token => [105]}},
          request.format.to_sym) }
    end
  end

  def not_found
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 404, 
        request.format.to_sym => format_response({ 
          :stat => "fail", 
          :err => {:record => [106]} },
          request.format.to_sym) }
    end
  end

end