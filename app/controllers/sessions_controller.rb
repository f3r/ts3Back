class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/sign_in.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/sign_in.json email=user@example.com&password=password
  # === Parameters
  # [:email]
  #   User email
  # [:password]
  #   User password
  # === Response
  # [:authentication_token]
  #   Returns the user authentication_token
  #   
  # === Error codes
  # [107]
  #   unconfirmed user
  # [108]
  #   unauthenticated user
  # [109]
  #   Invalid email or password
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
  # POST https://backend-heypal.heroku.com/users/twitter/sign_in.json access_token=access_token&oauth_token=oauth_token
  # === Parameters
  # [:access_token]
  #   Optional access token
  #
  # [:oauth_token]
  #   Optional oauth token
  #
  def oauth_create
    @user = User.find_for_oauth(params[:oauth_token], current_user) if params[:oauth_token]
    respond_with do |format|
      if @user
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
            :msg => "register please" },
            request.format.to_sym) }
      end
    end
    
  end
  
end