require 'declarative_authorization/maintenance'
include Authorization::TestHelper
class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel, :destroy ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update]
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  filter_access_to :all, :attribute_check => false

  # ==Description
  # This is the first step for a registration of new user. Just give us the name, email and password,
  # and we will send the user an email with a token to confirm the email address.
  #
  # Optionally, you can also send an oauth_token. We will save that authentication method and once
  # the account is confirmed, they can sign in with that account as well.
  # ==Resource URL
  # /users/sign_up.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/sign_up.json first_name=John&last_name=Smith&email=user@example.com&password=password
  # === Parameters
  # [first_name] User first name (Example values: John)
  # [last_name] User last name (Example values: Smith)
  # [email] User email address (Example values: user@example.com)
  # [password] User password
  # [oauth_token] Optional oauth token
  # === Response
  # [user]  An array containing the user ID
  # === Error codes
  # [100] has already been taken
  # [101] can't be blank
  # [102] too short
  # [103] is invalid
  # [104] doesn't match
  def create
    without_access_control do
      parameters = {  :first_name            => params[:first_name], 
                      :last_name             => params[:last_name], 
                      :email                 => params[:email], 
                      :password              => params[:password], 
                      :password_confirmation => params[:password],
                      :role                  => "user" }
      resource = resource_class.new(parameters)
      if resource.save
        if params[:oauth_token] && params[:oauth_token]['credentials']
          authentication = resource.authentications.create(
            :provider => params[:oauth_token]['provider'], 
            :uid => params[:oauth_token]['uid'], 
            :token => params[:oauth_token]['credentials']['token'], 
            :secret => params[:oauth_token]['credentials']['secret'])
        end
        return_message(200, :ok, {:user_id => resource.id})
      else
        return_message(200, :fail, {:err => format_errors(resource.errors.messages)})
      end
    end
  end
  
  # ==Description
  # Deactivates a user account. Deactivation means that the user account will be "soft deleted" for 1 month.
  # If they sign in, they will see a button that says "reactivate account".
  # After 1 month, all their data will be deleted for good.
  # ==Resource URL
  # /users.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/users.json access_token=access_token
  # === Parameters
  # [access_token]  User access token
  # === Error codes
  # [105] invalid access token
  # TODO: Create a "reactivation" method!
  def destroy
    check_token
    @user = current_user
    # TODO: Do we actually want to delete user or acts_as_paranoid? delete also it's data? transactions?
    if @user.destroy
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(resource.errors.messages)})
    end
  end

  # ==Description
  # Checks whether an email is already registered with us already
  # ==Resource URL
  # /users/check_email.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/check_email.json email=fer@heypal.com
  # === Parameters
  # [email] User email
  # === Error codes
  # [100] has already been taken
  def check_email
    user = User.find_by_email(params[:email])
    if user == nil
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => {:email => [100]}})
    end
  end
end