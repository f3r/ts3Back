class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel, :destroy ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update]
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/sign_up.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/sign_up.json email=user@example.com&password=password&password_confirmation=password
  # === Parameters
  # [:name]
  #   User full name
  #   Example values: John Smith
  #
  # [:email]
  #   User email address
  #   Example values: user@example.com
  #
  # [:password]
  #   User password
  #
  # [:oauth_token]
  #   Optional oauth token
  #
  # === Response
  # [:user]
  #   An array containing the users ID
  #
  # === Error codes
  # [1]
  # "has already been taken"
  #
  # [2]
  # "password too short"
  
  
  def create
    parameters = { :name => params[:name], :email => params[:email], :password => params[:password], :password_confirmation => params[:password]}
    resource = resource_class.new(parameters)
    respond_with do |format|
      if resource.save
        if params[:oauth_token]
          authentication = resource.authentications.create(
                              :provider => params[:oauth_token]['provider'], 
                              :uid => params[:oauth_token]['uid'], 
                              :oauth_token => params[:oauth_token]['credentials']['token'], 
                              :oauth_token_secret => params[:oauth_token]['credentials']['secret'])
        end
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response(
                                      { 
                                        :stat => "ok", 
                                        :user => { :id => resource.id }, 
                                        :msg => I18n.t("devise.registrations.signed_up")
                                      },
                                      request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response(
                                    { 
                                      :stat => "fail", 
                                      :error_codes => resource.errors
                                    },
                                    request.format.to_sym) }
                                    puts resource.errors.inspect
      end
    end
  end
  
  # ==Resource URL
  # /users.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/users.json access_token=access_token
  # === Parameters
  # [:access_token]
  def destroy
    check_token
    @user = current_user
    respond_with do |format|
      if @user.destroy
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :msg => I18n.t("devise.registrations.destroyed") },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => @user.errors },request.format.to_sym) }
      end
    end
  end

end