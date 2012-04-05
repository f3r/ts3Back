class AlertMailer < ActionMailer::Base
  add_template_helper(FrontendHelper)

  # ==Description
  # Email alert
  def send_alert(user, alert, city, new_results, recently_added)
    @alert = alert
    @user = user
    @city = city
    @new_results = new_results
    @recently_added = recently_added
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = 'Your places search alert'
    sent_on    =  Time.now
    mail(:from    => MAILER_SENDER,
         :to      => recipients,
         :subject => subject,
         :date    => sent_on)
  end

end