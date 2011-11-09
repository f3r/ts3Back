desc "Heroku cron add-on task to update all friends in facebook for every user"
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
  
  Authentication.where(:provider => "facebook").select("user_id").all.each{|foo|
    Delayed::Job.enqueue(FacebookImport.new(foo.user_id), -10)
  }
end