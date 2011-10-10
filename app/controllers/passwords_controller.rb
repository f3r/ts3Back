class PasswordsController < Devise::PasswordsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/password.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/password.json email=user@example.com
  # === Parameters
  # [:email]
  def create
    self.resource = resource_class.send_reset_password_instructions({:email => params[:email]})
    respond_with do |format|
      if successful_and_sane?(resource)
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :msg => I18n.t("devise.passwords.send_instructions") },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => resource.errors },request.format.to_sym) }
      end
    end
  end

  # ==Resource URL
  # /users/password.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users/password.json reset_password_token=reset_password_token&password=password&password_confirmation=password_confirmation
  # === Parameters
  # [:reset_password_token]
  # [:password]
  def update
    self.resource = resource_class.reset_password_by_token({:reset_password_token => params[:reset_password_token],:password => params[:password],:password_confirmation => params[:password]})
    respond_with do |format|
      if resource.errors.empty?
        if resource.active_for_authentication?
          response = { :stat => "ok", :user => { :authentication_token => resource.authentication_token }, :msg => I18n.t("devise.passwords.updated_not_active") }
        else
          response = { :stat => "ok", :msg => I18n.t("devise.passwords.updated_not_active") }
        end
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response(response,request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => resource.errors },request.format.to_sym) }
      end
    end
  end

end