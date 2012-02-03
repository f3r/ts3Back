class SystemMailer < ActionMailer::Base
  default :from => MAILER_SENDER,
          :to => ["jeremy@squarestays.com", "fer@squarestays.com"].join(',')
  
  def user_feedback(user, type, message)
    @user = user
    @type = type
    @message = message

    mail(:subject => "User Feedback (#{type})")
  end
end