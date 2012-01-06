class BankAccountsController < ApplicationController
  filter_access_to :all, :attribute_check => false
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  before_filter :get_user
  
  def initialize
    @fields = [
      :id, 
      :holder_name, 
      :holder_street, 
      :holder_city_name, 
      :holder_state_name, 
      :holder_country_name, 
      :holder_country_code, 
      :holder_zip,
      :account_number,
      :bank_code,
      :branch_code,
      :iban,
      :swift
    ]
  end
  
  # == Description
  # Returns all the bank_accounts of the current user
  # ==Resource URL
  # /users/:user_id/bank_accounts.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/341/bank_accounts.json
  # GET https://backend-heypal.heroku.com/users/me/bank_accounts.json
  # === Parameters
  # [access_token]
  def index
    @bank_accounts = @user.bank_accounts.select(@fields)
    if @bank_accounts.count > 0
      return_message(200, :ok, {:bank_accounts => @bank_accounts})
    else
      return_message(200, :ok, {:err => {:bank_account => [115]}})
    end
  end

  # == Description
  # Creates a new bank_account for the current user, must include street name, city and zip code
  # ==Resource URL
  # /users/:user_id/bank_accounts.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/341/bank_accounts.json access_token=access_token&street=street&holder_city_name=city&holder_country_code=SG&zip=zip
  # POST https://backend-heypal.heroku.com/users/me/bank_accounts.json access_token=access_token&street=street&holder_city_name=city&holder_country_code=SG&zip=zip
  # === Parameters
  # [access_token]
  # [street]                  Street name and number of the user
  # [holder_city_name]        City name
  # [holder_country_code]     Country code
  # [holder_country_name]     Country name
  # [zip]     Zip Code
  # == Errors
  # [101] can't be blank 
  # [116] Duplicate bank_account
  def create
    new_params = filter_params(params, @fields + [:holder_city_name])
    @bank_account = @user.bank_accounts.new(new_params)
    if @bank_account.save
      return_message(200, :ok, {:bank_account => filter_fields(@bank_account, @fields)} )
    else
      return_message(200, :fail, {:err => format_errors(@bank_account.errors.messages)})
    end
  end

  # == Description
  # Updates one of the current user's BankAccounts
  # ==Resource URL
  # /users/:user_id/bank_accounts/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users/341/bank_accounts/1.json access_token=access_token&street=street&holder_city_name=city&zip=zip
  # PUT https://backend-heypal.heroku.com/users/me/bank_accounts/1.json access_token=access_token&street=street&holder_city_name=city&zip=zip
  # === Parameters
  # [access_token]
  # [street]                  Street name and number of the user
  # [holder_city_name]        City name
  # [holder_country_code]     Country code
  # [holder_country_name]     Country name
  # [zip]     Zip Code
  # == Errors
  # [101] can't be blank 
  # [116] Duplicate bank_account
  def update
    @bank_account = @user.bank_accounts.find(params[:id])
    new_params = filter_params(params, @fields + [:holder_city_name])
    if @bank_account.update_attributes(new_params)
      return_message(200, :ok, {:bank_account => filter_fields(@bank_account, @fields)} )  
    else
      return_message(200, :fail, {:err => format_errors(@bank_account.errors.messages)})
    end
  end

  # == Description
  # Deletes one of the bank_accounts of the current user
  # ==Resource URL
  # /users/:user_id/bank_accounts/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/users/341/bank_accounts/:id.json access_token=access_token
  # DELETE https://backend-heypal.heroku.com/users/me/bank_accounts/:id.json access_token=access_token
  # === Parameters
  # [access_token]
  def destroy
    @bank_account = @user.bank_accounts.find(params[:id])
    if @bank_account.destroy
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(@bank_account.errors.messages)})
    end
  end

  protected
  def get_user
    if params[:user_id] && params[:user_id].to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil # is numeric
      id = params[:user_id]
    elsif params[:user_id] == "me" && current_user
      id = current_user.id
    end
    @user = User.find(id) if id
  end

end