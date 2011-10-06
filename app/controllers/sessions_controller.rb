class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token

  # ==Resource URL
  # http://backend-heypal.heroku.com/users/sign_in.format
  # ==Example
  # POST http://backend-heypal.heroku.com/users/sign_in.json email=user@example.com&password=password
  # === Parameters
  # [:email]
  # [:password]
  def create
    params[resource_name] = { :email => params[:email], :password => params[:password] }
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    respond_to do |format|
      if resource
        response = { :stat => "ok", :user => { :id => resource.id, :authentication_token => resource.authentication_token }, :msg => I18n.t("devise.sessions.signed_in") }
        format.json { render :status => 200, :json => response }
        format.xml { render :status => 200, :xml => response.to_xml(:root => "rsp") }
      end
    end
  end
  
  def failure
    respond_to do |format|
      response = { :stat => "fail", :err => error_message }
      format.json { render :status => 401, :json => response }
      format.xml { render :status => 401, :xml => response.to_xml(:root => "rsp") }
    end
  end

end