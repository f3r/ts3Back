class Notification

  # Complete Mapping of notification types/events/contents is in doc/README_FOR_APP
  attr_accessor :notification_type, :event, :content
  
  # == Description
  # Adds a notification to the current user
  # == Parameters
  # [Type]    String with the superclass of event that generated it (ie "Requests", "Places")
  # [Event]   String with the code of the event that generated it (ie "Rental Request")
  # [Content] Hash with all the relevant parameters for the event (ie "requestor_id", "place_id", etc)
  #
  # All notifications are added automatically a Date field, with the time it was generated
  def save
    notification      = {:date              => DateTime.now.to_s}
    notification.merge!({:notification_type => self.notification_type})
    notification.merge!({:event             => self.event})
    notification.merge!({:content           => self.content})
    REDIS.zadd(Notification.key, Notification.score, notification.to_json)

    # TODO: Add mailer notifications in here!
    return true
  end
  
  # Returns an array with all the notifications for the current user
  def self.all
    return REDIS.zrange(Notification.key, 0, -1)
  end
  
  # Return all unread notifications
  def self.unread
    last_read = REDIS.get Notification.key_read
    return REDIS.zrangebyscore(Notification.key, last_read, Notification.score)
  end

  # Stores the last_read_on for the current user so later we can retrieve NEW notifications
  def self.mark_as_read
    REDIS.set Notification.key_read, Notification.score
  end

private
  # helper method to generate redis notifications keys
  def self.key
    "notifications:#{Authorization.current_user.id}"
  end

  # helper method to generate redis last_read_on keys
  def self.key_read
    "notifications-read-on:#{Authorization.current_user.id}" 
  end
  
  # Helper method to generate the timestamp based on unix time
  def self.score
    DateTime.now.to_time.to_i
  end

  # Helper method to generate the timestamp based on unix time
  def self.score_one_month_ago
    (DateTime.now - 1.month).to_time.to_i
  end
end
