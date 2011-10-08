class ApplicationController < ActionController::Base
  include Exceptions
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

  def unauthorized_access
    respond_with do |format|
      format.any(:xml, :json) { render :status => 401, request.format.to_sym => format_response({ :stat => "fail", :msg => I18n.t("devise.failure.invalid_token") },request.format.to_sym) }
    end
  end

  def current_user
    warden.user || User.find_for_token_authentication(:auth_token => params[:access_token])
  end

end