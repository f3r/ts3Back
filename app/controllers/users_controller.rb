class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/:id/info.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/:id/info.json
  # === Parameters
  # [:id] User id
  # === Response
  # [:user]  An array containing {id, profile_pic, name, review_count, badges_count}
  # === Error codes
  # [106] no user exists
  def info
    fields = [:id, :name, :avatar_file_name]
    @user = Rails.cache.fetch("user_info_" + params[:id].to_s) { User.select(fields).find(params[:id]) }
    respond_with do |format|
      if @user
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok",
            :user => filter_fields(@user, fields, {:style => :thumb})
            # TODO: Add review/badges when implemented
            # :review_count  => @user.review_count,
            # :badges_count  => @user.badges.count
            },
            request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => {:user => [112]}},
            request.format.to_sym) }
      end
    end
  end

  # ==Resource URL
  # /users.format
  # /users/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users.json access_token=access_token
  # GET https://backend-heypal.heroku.com/users/1.json access_token=access_token
  # === Parameters
  # [:access_token] Access token
  # [:id] Optional user id
  # === Response
  # [:user] User array containing the user data
  # === Error codes
  # [105] invalid access token
  def show
    check_token
    id = params[:id].nil? ? current_user.id : params[:id]
    fields = [:id, :name, :gender, :birthdate, :timezone, :phone_home, :phone_mobile, :phone_work, :avatar_file_name]
    @user = Rails.cache.fetch("user_full_info_" + id.to_s) { User.select(fields).find(id) }
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok",
          :user => filter_fields(@user,fields) },
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
            :err => format_errors(@user.errors.messages) },
            request.format.to_sym) }
      end
    end
  end

end