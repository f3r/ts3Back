require 'declarative_authorization/maintenance'
include Authorization::TestHelper
class PasswordsController < Devise::PasswordsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  filter_access_to :all, :attribute_check => false

  # ==Description
  # If a user forgets the password, you call this url with the email
  # and we will send him an email with a special token to reset it
  # ==Resource URL
  # /users/password.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/password.json email=user@example.com
  # === Parameters
  # [email]
  # === Error codes
  # [106] email not found
  def create
    without_access_control do
      self.resource = resource_class.send_reset_password_instructions({:email => params[:email]})
      if successfully_sent?(resource)
        return_message(200, :ok)
      else
        return_message(200, :fail, {:err => { :email => "106" }})
      end
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
  # [reset_password_token] Reset password token sent by email
  # [password]  The new password
  # === Response
  # [authentication_token] Returns the user authentication_token if the account is active
  # === Error codes
  # [101] can't be blank
  # [102] too short
  # [103] invalid reset_password_token
  def update
    without_access_control do
      if params[:reset_password_token] && params[:password]
        self.resource = resource_class.reset_password_by_token({
          :reset_password_token => params[:reset_password_token],
          :password => params[:password],
          :password_confirmation => params[:password]})
        if resource.errors.empty?
          if resource.active_for_authentication?
            return_message(200, :ok, {:authentication_token => resource.authentication_token, :role => resource.role})
          else
            return_message(200, :ok)
          end
        else
          return_message(200, :fail, {:err => format_errors(resource.errors.messages) })
        end
      else
        return_message(200, :fail, {:err => {:password => 101} })
      end
    end
  end
end