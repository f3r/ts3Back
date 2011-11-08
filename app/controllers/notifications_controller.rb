class NotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # == Description
  # Returns all the notifications of the current user
  # ==Resource URL
  # /notifications.format
  # ==Example
  # GET https://backend-heypal.heroku.com/notifications.json
  # === Parameters
  # [:access_token]
  # == Errors
  # [115] no result
  def index
    check_token
    
    @notifications = []
    Notification.all.each{|foo|
      @notifications << ActiveSupport::JSON::decode(foo)
      }
    if @notifications
      return_message(200, :ok, {:notifications => @notifications})
    else
      return_message(200, :ok, {:err => {:notifications => [115]}})
    end
  end

  # == Description
  # Returns all the unread notifications of the current user
  # ==Resource URL
  # /notifications/unread.format
  # ==Example
  # GET https://backend-heypal.heroku.com/notifications/unread.json
  # === Parameters
  # [:access_token]
  # == Errors
  # [115] no results
  def unread
    check_token
    
    @notifications = []
    Notification.unread.each{|foo|
      @notifications << ActiveSupport::JSON::decode(foo)
      }
    if @notifications
      return_message(200, :ok, {:notifications => @notifications})
    else
      return_message(200, :ok, {:err => {:notifications => [115]}})
    end
  end
  
  # == Description
  # Marks
  # ==Resource URL
  # /notifications/mark_as_read.format
  # ==Example
  # GET https://backend-heypal.heroku.com/notifications/mark_as_read.json
  # === Parameters
  # [:access_token]
  def mark_as_read
    check_token    
    Notification.mark_as_read
    return_message(200, :ok)
  end  
end