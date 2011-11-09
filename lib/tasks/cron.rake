desc "Heroku cron add-on tasks"
task :cron => :environment do
  # HEROKU SAMPLE CODE
  # run every four hours
  # if Time.now.hour == 4 
  #   puts "Updating feed..."
  #   NewsFeed.update
  #   puts "done."
  # end
  # 
  # if Time.now.hour == 0 # run at midnight
  #   User.send_reminders
  # end
  
  # Update Facebook Friends for each user with facebook account linked
  Authentication.where(:provider => "facebook").select("user_id").all.each{|foo|
    Delayed::Job.enqueue(FacebookImport.new(foo.user_id), -10)
  }
  
  # We only store notifications for a month, so we delete older notifications for all users
  User.all.each {|user|
    REDIS.zremrangebyscore("notifications:#{user.id}", 0, Notification.score_one_month_ago)
  }
  
end