class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

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
  
  # ==Resource URL
  # /users/:provider/sign_in.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/twitter/sign_in.json oauth_token=oauth_token
  # === Parameters
  # [:provider]     Name of the oAuth provider
  # [:oauth_token]  oAuth token
  # === Error codes
  # [110] Must sign up
  def oauth_create
    user_id = Authentication.find_by_provider_and_token(params[:provider], params[:oauth_token], :select => "user_id")
    respond_with do |format|
      if user_id
        if @user = User.find(user_id['user_id'])
          format.any(:xml, :json) { 
            render :status => 200, 
            request.format.to_sym => format_response({ 
              :stat => "ok", 
              :authentication_token => @user.authentication_token },
              request.format.to_sym) }
        else
          format.any(:xml, :json) { 
            render :status => 401, 
            request.format.to_sym => format_response({ 
              :stat => "fail", 
              :err => {:user => [110]} }, #TODO: This error must be oauth_token exists, but user doesn't... wierd but true!
              request.format.to_sym) }
        end
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