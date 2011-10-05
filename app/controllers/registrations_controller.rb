class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token

  # ==Resource URL
  # http://backend-heypal.heroku.com/users.format
  # ==Example
  # POST http://backend-heypal.heroku.com/users.json email=user@example.com&password=password&password_confirmation=password
  # === Parameters
  # [:email]
  # [:password]
  # [:password_confirmation]
  def create
    parameters = {:email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation]}
    resource = resource_class.new_with_session(parameters, session)
    respond_to do |format|
      if resource.save
          response = { :stat => "ok", :msg => I18n.t("devise.registrations.signed_up") }
          format.json { render :status => 200, :json => response }
          format.xml { render :status => 200, :xml => response.to_xml(:root => "rsp") }
      else
          response = { :stat => "fail", :err => resource.errors }
          format.json { render :status => 401, :json => response.to_json }
          format.xml { render :status => 401, :xml => response.to_xml(:root => "rsp") }
      end
    end
  end

end