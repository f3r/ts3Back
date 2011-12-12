class UserMailer < ActionMailer::Base  
  default :from     => 'SquareStays.com <noreply@squarestays.com>',
          # Settings version => "#{@site_name} <#{Setting.contact_email}>"
          :reply_to =>  'SquareStays.com <noreply@squarestays.com>'

# ==Description
# Email sent when the user confirms the account
# TODO: figure out html/txt sending (user preferences?)
def welcome_note(user)
  begin
    @user      = user
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = 'Welcome to SquareStays'
    sent_on    =  Time.now
    mail(:to => recipients, :subject => subject, :date => sent_on) do |format|
      format.text
      format.html
    end
  rescue Exception => e
    logger.error { "Error [user_mailer.rb/send_welcome_note] #{e.message}" }
  end
end

end