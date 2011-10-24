class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/confirmation.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/confirmation.json email=user@example.com
  # === Parameters
  # [:email] Email used on registration
  # === Error codes
  # [106] email not found
  def create
    self.resource = resource_class.send_confirmation_instructions({:email => params[:email]})
    respond_with do |format|
      if successful_and_sane?(resource)
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok"}, 
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
  # [:confirmation_token]
  #   Confirmation token sent by email
  # === Response
  # [:authentication_token] The user authentication_token
  # === Error codes
  # [103] invalid confirmation_token
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    respond_with do |format|
      if resource.errors.empty?
        # New user! Now we send them a nice welcome email
        UserMailer.welcome_note(resource).deliver
        format.any(:xml, :json) { 
          render :status => 200,
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :authentication_token => resource.authentication_token }, 
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 401, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => {:confirmation_token => "103"} },
            request.format.to_sym) }
      end
    end
  end

end