class ApplicationController < ActionController::Base
  rescue_from Exceptions::UnauthorizedAccess, :with => :unauthorized_access
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :not_found
  rescue_from ActionController::UnknownAction, :with => :not_found

  protect_from_forgery

  def format_response(response,format)
    method = "to_#{format}"
    if method == "to_xml"
      response.to_xml(:root => "rsp", :dasherize => false)
    else
      response.send(method)
    end
  end

  def authenticated?
    if warden.authenticated?
      return true
    elsif params[:access_token] and User.find_for_token_authentication(:auth_token => params[:access_token])
      return true
    else
      return false
    end
  end

  def current_user
    warden.user || User.find_for_token_authentication(:auth_token => params[:access_token])
  end

  def unauthorized_access
    respond_with do |format|
      format.any(:xml, :json) { render :status => 401, request.format.to_sym => format_response({ :stat => "fail", :msg => I18n.t("devise.failure.invalid_token") },request.format.to_sym) }
    end
  end

  def not_found
    respond_with do |format|
      format.any(:xml, :json) { render :status => 404, request.format.to_sym => format_response({ :stat => "fail", :err => I18n.t("not_found") },request.format.to_sym) }
    end
  end

end