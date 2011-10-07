class ApplicationController < ActionController::Base
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
      self.status = 401
      self.content_type = request.format.to_s
      self.response_body = format_response({:stat => "fail", :err => I18n.t("devise.failure.invalid_token")},params[:format])
      return false
    end
  end

  def current_user
    warden.user || User.find_for_token_authentication(:auth_token => params[:access_token])
  end

end