require 'declarative_authorization/maintenance'
include Authorization::TestHelper
class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  filter_access_to :all, :attribute_check => false

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
    without_access_control do
      params[resource_name] = { :email => params[:email], :password => params[:password] }
      resource = warden.authenticate!(:scope => resource_name)
      if resource
        return_message(200, :ok, {:authentication_token => resource.authentication_token, :role => resource.role})
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
  #   oauth_token[provider]=facebook&
  #   oauth_token[credentials][token]=token
  # === Error codes
  # [110] Must sign up
  def oauth_create
    if params[:oauth_token]
      authentication = Authentication.find_by_provider_and_token(
        params[:oauth_token]['provider'], 
        params[:oauth_token]['credentials']['token']
      )
    end

    if authentication
      
      return_message(200, :ok, {:authentication_token => authentication.user.authentication_token, :role => authentication.user.role})
    else
      return_message(401, :fail, {:err => {:user => [110]}})
    end
  end
end