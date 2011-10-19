class PasswordsController < Devise::PasswordsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/password.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/password.json email=user@example.com
  # === Parameters
  # [:email]
  # === Error codes
  # [106] email not found
  def create
    self.resource = resource_class.send_reset_password_instructions({:email => params[:email]})
    respond_with do |format|
      if successful_and_sane?(resource)
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok" },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => { :email => "106" } },
            request.format.to_sym) }
      end
    end
  end

  # ==Resource URL
  # /users/password.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users/password.json reset_password_token=reset_password_token&password=password
  # === Parameters
  # [:reset_password_token] Reset password token sent by email
  # [:password]  The new password
  # === Response
  # [:authentication_token] Returns the user authentication_token if the account is active
  # === Error codes
  # [103] invalid reset_password_token
  def update
    self.resource = resource_class.reset_password_by_token({
      :reset_password_token => params[:reset_password_token],
      :password => params[:password],
      :password_confirmation => params[:password]})
    respond_with do |format|
      if resource.errors.empty?
        if resource.active_for_authentication?
          response = { :stat => "ok", :authentication_token => resource.authentication_token }
        else
          response = { :stat => "ok" }
        end
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response(response,request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => { :reset_password_token => "103" } },
            request.format.to_sym) }
      end
    end
  end

end