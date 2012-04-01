class AlertMailer < ActionMailer::Base

  # ==Description
  # Email alert
  def send_alert(user, new_results, recently_added)
    @user = user
    @new_results = new_results
    @recently_added = recently_added
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = 'Alert!'
    sent_on    =  Time.now
    mail(:from    => MAILER_SENDER,
         :to      => recipients,
         :subject => subject,
         :date    => sent_on)
  end

end