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
  # TODO: Add error code if no user exists
  # [10X] no user exists
  def info
    #TODO: scope response only for fields needed
    #TODO: add memcached
    @user = User.find(params[:id]) 
    respond_with do |format|
      if @user
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok",
            :user_info => {
              :id            => @user.id,
              :profile_pic   => @user.avatar_file_name,
              :name          => @user.name #,
              # TODO: Add review/badges when implemented
              # :review_count  => @user.review_count,
              # :badges_count  => @user.badges.count
            }},
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
            :err => format_errors(@user.errors.messages) },
            request.format.to_sym) }
      end
    end
  end

end