class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users.json access_token=access_token
  # === Parameters
  # [:access_token]
  #   Access token
  # === Response
  # [:user] User array containing the new data
  # === Error codes
  # [105] invalid access token
  def show
    check_token
    @user = current_user
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok",
          :user => @user },
          request.format.to_sym) }
    end
  end

  # ==Resource URL
  # /users.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users.json access_token=access_token
  # === Parameters
  # [:access_token]
  #   Access token
  # === Response
  # [:user] User array containing the new data
  # === Error codes
  # [105] invalid access token
  # [101] can't be blank
  # [103] is invalid
  # [113] invalid date
  def update
    check_token
    @user = current_user
    respond_with do |format|
      if @user.update_attributes(params[:user])
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok",
            :user => @user },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@user.errors) },
            request.format.to_sym) }
      end
    end
  end

end