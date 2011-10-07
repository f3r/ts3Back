class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel, :destroy ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update]
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/sign_up.format
  # ==Example
  # POST http://backend-heypal.heroku.com/users/sign_up.json email=user@example.com&password=password&password_confirmation=password
  # === Parameters
  # [:email]
  # [:password]
  # [:password_confirmation]
  def create
    parameters = {:email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation]}
    resource = resource_class.new(parameters)
    respond_with do |format|
      if resource.save
          response = { :stat => "ok", :user => { :id => resource.id, :confirmation_token => resource.confirmation_token }, :msg => I18n.t("devise.registrations.signed_up") }
          format.json { render :status => 200, :json => response }
          format.xml { render :status => 200, :xml => response.to_xml(:root => "rsp") }
      else
          response = { :stat => "fail", :err => resource.errors }
          format.json { render :status => 200, :json => response.to_json }
          format.xml { render :status => 200, :xml => response.to_xml(:root => "rsp") }
      end
    end
  end

  # ==Resource URL
  # /users.format
  # ==Example
  # DELETE http://backend-heypal.heroku.com/users.json
  # === Parameters
  # [:authentication_token]
  def destroy
    begin
      resource = User.find_by_authentication_token(params[:authentication_token])
    rescue Exception => e
      error_message = e.message
    end
    respond_with do |format|
      if resource && resource.destroy
        response = { :stat => "ok", :msg => I18n.t("devise.registrations.destroyed") }
        format.json { render :status => 200, :json => response }
        format.xml { render :status => 200, :xml => response.to_xml(:root => "rsp") }
      else
        response = { :stat => "fail", :err => error_message }
        format.json { render :status => 200, :json => response }
        format.xml { render :status => 200, :xml => response.to_xml(:root => "rsp") }
      end
    end
  end

end