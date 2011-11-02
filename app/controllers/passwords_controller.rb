class PasswordsController < Devise::PasswordsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Description
  # If a user forgets the password, you call this url with the email
  # and we will send him an email with a special token to reset it
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
    if successful_and_sane?(resource)
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => { :email => "106" }})
    end
  end

  # ==Description
  # Once the user receives a "forget password" email, you can call this method to reset
  # the password. It requires the sent token and the new password.
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

    if resource.errors.empty?
      if resource.active_for_authentication?
        return_message(200, :ok, {:authentication_token => resource.authentication_token})
      else
        return_message(200, :ok)
      end
    else
      return_message(200, :fail, {:err => { :reset_password_token => "103" }})
    end
  end
end