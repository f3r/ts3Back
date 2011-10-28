class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Description
  # Returns all the public information of a specific user (id, profile_pict, name)
  # ==Resource URL
  # /users/:id/info.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/:id/info.json
  # === Parameters
  # [:id] User id
  # === Response
  # [:user]
  # {id, profile_pic, name, review_count, badges_count}
  # === Error codes
  # [106] no user exists
  def info
    fields = [:id, :first_name, :last_name, :avatar_file_name]
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

  # ==Description
  # Returns all the information of the current user
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
  # [:user]
  # {:id, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_home, :phone_mobile, :phone_work, :avatar_file_name}
  # === Error codes
  # [105] invalid access token
  def show
    check_token
    id = params[:id].nil? ? current_user.id : params[:id]
    fields = [:id, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_home, :phone_mobile, :phone_work, :avatar_file_name]
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

  # ==Description
  # Updates the information for an authenticated user. 
  #
  # *Note:* User fields must be enclosed with square brackets, not with periods
  # ==Resource URL
  # /users.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users.json access_token=access_token&user.avatar_url=http://url/image_file
  # === Parameters
  # [:access_token]     Access token
  # [user.first_name]   First name of the user
  # [user.last_name]    Last name of the user
  # [user.gender]       Gender: unkown/male/female
  # [user.birthdate]    Birthdate of the user, stored in same format as ruby::Date
  # [user.timezone]     Based on TimeZone::to_s http://tzinfo.rubyforge.org/doc/classes/TZInfo/Timezone.html#M000048
  # [user.phone_home]   Home Phone number, including country code
  # [user.phone_mobile] Mobile Phone number, including country code
  # [user.phone_work]   Work Phone number, including country code
  # [user.avatar_url]   avatar picture from url, i.e. http://url/image_file
  # === Response
  # [:user]
  # {:id, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_home, :phone_mobile, :phone_work, :avatar_file_name}
  # === Error codes
  # [105] invalid access token
  # [101] can't be blank
  # [103] is invalid
  # [113] invalid date
  def update
    check_token
    fields = [:id, :first_name, :last_name, :gender, :birthdate, :timezone, :phone_home, :phone_mobile, :phone_work, :avatar_file_name]
    @user = current_user
    respond_with do |format|
      if @user.update_attributes(params[:user])
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok",
            :user => filter_fields(@user,fields) },
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