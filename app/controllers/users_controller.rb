class UsersController < ApiController
  before_filter :get_user, :only => [:update, :show, :change_role, :transactions, :feedback]
  
  def initialize
    @fields = [
      :id,
      :email,
      :unconfirmed_email,
      :first_name, 
      :last_name, 
      :gender, 
      :birthdate, 
      :timezone, 
      :phone_mobile, 
      :passport_number, 
      :avatar_file_name,
      :pref_language,
      :pref_currency,
      :pref_size_unit,
      :role
    ]

    @transaction_fields = [
      :id, :state, :check_in, :check_out, :transaction_code,
      :currency, :price_per_night, :price_final_cleanup, :price_security_deposit, :sub_total
    ]
    
    @place_details = [
      :title, :city_name, :state_name, :country_name
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
    @user = Rails.cache.fetch("user_info_" + params[:id].to_s) { User.find(params[:id]) }
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
  # {:id, :email, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_mobile, :passport_number, :avatar_file_name, :pref_language, :pref_currency}
  # === Error codes
  # [105] invalid access token
  def show
    if @user && (permitted_to? :read, @user)
      # TODO: add to additional_fields method, caching
      if !@user.addresses.blank?
        address = filter_fields(@user.addresses.first,[:street, :city, :country, :zip])
      else
        address = nil
      end
      return_message(200, :ok, {:user => filter_fields(@user,@fields).merge!({:address => address})})
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
  # [passport_number]  String, Passport number
  # [avatar_url]    String, avatar picture from url, i.e. http://url/image_file
  # [pref_language] String, Preferred Language. ie "en"
  # [pref_currency] String, Preferred Currency. ie "USD"
  # [pref_size_unit] String, Preferred Size unit. ie "sqm"
  # === Response
  # [user]
  # {:id, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_mobile, passport_number, :avatar_file_name, :pref_language, :pref_currency, :pref_size_unit}
  # === Error codes
  # [105] invalid access token
  # [101] can't be blank
  # [103] is invalid
  # [113] invalid date
  # [139] date must be on the past
  def update
    fields = [
      :id,
      :first_name, 
      :last_name, 
      :gender, 
      :birthdate, 
      :timezone, 
      :phone_mobile, 
      :passport_number, 
      :avatar,
      :avatar_url,
      :pref_language,
      :pref_currency,
      :pref_size_unit,
      :email,
      :password,
      :password_confirmation
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

  # == Description
  # Requests a place
  # ==Resource URL
  #   /users/:id/transactions.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/users/:id/transactions.json access_token=access_token&status=active
  # === Parameters
  # [access_token]  Access token
  # [status] Options: active, inactive, any, Defaults to active
  # === Error codes
  # [106] Record not found
  # [115] no results
  def transactions
    case params[:status]
    when "active"
      transactions = @user.transactions.active
    when "inactive"
      transactions = @user.transactions.inactive
    when "any"
      transactions = @user.transactions
    else
      transactions = @user.transactions.active
    end

    if !transactions.blank?
      transactions_return = { 
        :transactions => filter_fields(
          transactions,
          @transaction_fields,
          {
            :additional_fields => { :place => @place_details }
          }
        )
      }
      return_message(200, :ok, transactions_return)
    else
      return_message(200, :ok, {:err=>{:transactions => [115]}} )
    end

  end

  # == Description
  # Requests a place
  # ==Resource URL
  #   /users/feedback.format
  # ==Example
  #   POST https://backend-heypal.heroku.com/users/feedback.json access_token=access_token
  # === Parameters
  # [access_token] Access token
  # [type] Feedback category: city_suggestion, ...
  # [message] The message
  def feedback
    SystemMailer.user_feedback(current_user, params[:type], params[:message]).deliver!
    return_message(200, :ok)
  end

  protected
  def get_user
    if params[:id]
      id = params[:id]
    elsif current_user
      id = current_user.id
    end
    @user = User.find(id) if id
  end
end