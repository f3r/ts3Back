require 'declarative_authorization/maintenance'
include Authorization::TestHelper
class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  filter_access_to :all, :attribute_check => false

  # ==Resource URL
  # /users/confirmation.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/confirmation.json email=user@example.com
  # === Parameters
  # [email] Email used on registration
  # === Error codes
  # [106] email not found
  def create
    without_access_control do
      self.resource = resource_class.send_confirmation_instructions({:email => params[:email]})
      if successfully_sent?(resource)
        return_message(200, :ok)
      else
        return_message(200, :fail, {:err => { :email => "106" }})
      end
    end
  end

  # ==Description
  # Once a user receives the registration email, this method activates the account.
  #
  # The token sent in the email must be passed along. If it is correct, we will send
  # the user a welcome email, because we are THAT nice :)
  # ==Resource URL
  # /users/confirmation.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/confirmation.json confirmation_token=confirmation_token
  # === Parameters
  # [confirmation_token]
  #   Confirmation token sent by email
  # === Response
  # [authentication_token] The user authentication_token
  # === Error codes
  # [103] invalid confirmation_token
  def show
    without_access_control do
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      if resource.errors.empty?
        # New user! Now we send them a nice welcome email
        UserMailer.welcome_note(resource).deliver if resource.last_sign_in_at.nil? # do not send if user already sign in (email reconfirmation)
        return_message(200, :ok, {:authentication_token => resource.authentication_token, :role => resource.role})
      else
        return_message(401, :fail, {:err => {:confirmation_token => "103"}})
      end
    end
  end

end