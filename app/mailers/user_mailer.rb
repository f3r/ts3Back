class UserMailer < ActionMailer::Base  

  # ==Description
  # Email sent when the user confirms the account
  def welcome_note(user)
    begin
      @user      = user
      recipients = "#{user.full_name} <#{user.email}>"
      subject    = 'Welcome to SquareStays'
      sent_on    =  Time.now
      mail(:from => MAILER_SENDER, 
           :to => recipients, 
           :subject => subject, 
           :date => sent_on) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [user_mailer.rb/welcome_note] #{e.message}" }
    end
  end

  # ==Description
  # Email sent when the user receives a message
  def new_message(user, msg_id)
    @user      = user
    @msg_id    = msg_id
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = 'You have a new message!'
    sent_on    =  Time.now
    mail(:from    => MAILER_SENDER,
         :to      => recipients,
         :subject => subject,
         :date    => sent_on)
  end

  # ==Description
  # Email sent when the user receives a message
  def new_message_admin(from_user, to_user, message)
    begin
      @from_user = from_user
      @to_user   = to_user
      @message   = message
      recipients = "jeremy@heypal.com, fer@heypal.com"
      subject    = "#{@to_user.full_name} has a new message!"
      sent_on    =  Time.now
      mail(:from    => MAILER_SENDER,
           :to      => recipients,
           :subject => subject,
           :date    => sent_on) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [user_mailer.rb/new_message] #{e.message}" }
    end
  end
end