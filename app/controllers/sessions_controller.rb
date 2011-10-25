class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Description
  # Given an email and password, this method returns the authentication token of the user so you can
  # send requests on their behalf
  # ==Resource URL
  # /users/sign_in.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/sign_in.json email=user@example.com&password=password
  # === Parameters
  # [:email]    User email
  # [:password] User password
  # === Response
  # [:authentication_token] Returns the user authentication_token
  # === Error codes
  # [107] unconfirmed user
  # [108] unauthenticated user
  # [109] Invalid email or password
  def create
    params[resource_name] = { :email => params[:email], :password => params[:password] }
    resource = warden.authenticate!(:scope => resource_name)
    respond_with do |format|
      if resource
          format.any(:xml, :json) { 
            render :status => 200, 
            request.format.to_sym => format_response({ 
              :stat => "ok", 
              :authentication_token => resource.authentication_token },
              request.format.to_sym) }
      end
    end
  end
  # Error message override is at /lib/custom_failure.rb
  
  # ==Description
  # Given an provider and provider token, this method returns the authentication token of the user so you can
  # send requests on their behalf
  # ==Resource URL
  # /users/oauth/sign_in.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/oauth/sign_in.json oauth_token=oauth_token
  # === Parameters
  # [:oauth_token]  oAuth token
  # === Error codes
  # [110] Must sign up
  def oauth_create
    if params[:oauth_token]
      authentication = Authentication.find_by_provider_and_token(
        params[:oauth_token]['provider'], 
        params[:oauth_token]['credentials']['token']
      )
    end
    respond_with do |format|
      if authentication
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :authentication_token => authentication.user.authentication_token },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 401, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => {:user => [110]} },
            request.format.to_sym) }
      end
    end
  end
end