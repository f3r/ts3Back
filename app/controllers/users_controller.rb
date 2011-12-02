class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  before_filter :get_user, :only => [:update, :show, :change_role]
  filter_access_to :all, :attribute_check => false
  
  def initialize
    @fields = [
      :id,
      :email,
      :first_name, 
      :last_name, 
      :gender, 
      :birthdate, 
      :timezone, 
      :phone_mobile, 
      :avatar_file_name,
      :pref_language,
      :pref_currency
    ]
  end

  # ==Description
  # Returns all the public information of a specific user
  # ==Resource URL
  # /users/:id/info.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/:id/info.json
  # === Parameters
  # [id] User id
  # === Response
  # [user]
  # {id, first_name, last_name, avatar_file_name, role}
  # === Error codes
  # [106] no user exists
  def info
    fields = [:id, :first_name, :last_name, :avatar_file_name, :role]
    @user = Rails.cache.fetch("user_info_" + params[:id].to_s) { User.select(fields).find(params[:id]) }
    if permitted_to? :info, @user
      return_message(200, :ok, {:user => filter_fields(@user, fields, {:style => :thumb})})
    else
      return_message(200, :fail, {:err => {:user => [112]}})
    end
  end

  # ==Description
  # Returns all the information of the current user
  # ==Resource URL
  # /users.format
  # /users/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users.json access_token=access_token
  # GET https://backend-heypal.heroku.com/users/1.json access_token=access_token
  # === Parameters
  # [access_token] Access token
  # [id] Optional user id
  # === Response
  # [user]
  # {:id, :email, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_mobile, :avatar_file_name, :pref_language, :pref_currency}
  # === Error codes
  # [105] invalid access token
  def show
    if @user && (permitted_to? :read, @user)
      return_message(200, :ok, {:user => filter_fields(@user,@fields)})
    else
      attribute_authorization_error
    end
  end

  # ==Description
  # Updates the information for an authenticated user. 
  #
  # *Note:* User fields must be enclosed with square brackets, not with periods
  # ==Resource URL
  # /users.format
  # /users/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users.json access_token=access_token&avatar_url=http://url/image_file
  # PUT https://backend-heypal.heroku.com/users/1.json access_token=access_token&avatar_url=http://url/image_file
  # === Parameters
  # [access_token] Access token
  # [first_name]    String, First name of the user
  # [last_name]     String, Last name of the user
  # [gender]        String, Gender. Values: unkown/male/female
  # [birthdate]     Date, Birthdate of the user, stored in same format as ruby::Date, Ex. 1981-12-31, 1981/09/31
  # [timezone]      Based on TimeZone::to_s http://tzinfo.rubyforge.org/doc/classes/TZInfo/Timezone.html#M000048
  # [phone_mobile]  String, Mobile Phone number, including country code
  # [avatar_url]    String, avatar picture from url, i.e. http://url/image_file
  # [pref_language] String, Preferred Language. ie "en"
  # [pref_currency] String, Preferred Currency. ie "USD"
  # === Response
  # [user]
  # {:id, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_mobile, :avatar_file_name, :pref_language, :pref_currency}
  # === Error codes
  # [105] invalid access token
  # [101] can't be blank
  # [103] is invalid
  # [113] invalid date
  def update
    fields = [
      :id,
      :first_name, 
      :last_name, 
      :gender, 
      :birthdate, 
      :timezone, 
      :phone_mobile, 
      :avatar,
      :avatar_url,
      :pref_language,
      :pref_currency
    ]
    new_params = filter_params(params, fields)
    if @user.update_attributes(new_params)
      return_message(200, :ok, {:user => filter_fields(@user,@fields)})
    else
      return_message(200, :fail, {:err => format_errors(@user.errors.messages)})
    end
  end

  # ==Description
  # Changes a users role
  # ==Resource URL
  # /users/:id/change_role.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users/1/change_role.json access_token=access_token&role=admin
  # === Parameters
  # [access_token] Access token
  # [role] New role, Options: superadmin, admin, agent, user
  # === Error codes
  # [105] invalid access token
  # [101] can't be blank
  # [103] is invalid
  def change_role
    if !params[:role].blank? && params[:role] != @user.role
      if @user.update_attributes({:role => params[:role]})
        return_message(200, :ok)
      else
        return_message(200, :fail, {:err => format_errors(@user.errors.messages)})
      end
    elsif !params[:role].blank? && params[:role] == @user.role # no change
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => {:role => [101]}})
    end
  end

  protected
  def get_user
    if params[:id]
      id = params[:id]
    elsif current_user
      id = current_user.id
    end
    # @user = Rails.cache.fetch("user_" + id.to_s) { User.find(id) } if id
    @user = User.find(id) if id
  end
end