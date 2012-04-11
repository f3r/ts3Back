class SystemMailer < ActionMailer::Base
  default :from => MAILER_SENDER,
          :to => ["jeremy@squarestays.com", "fer@squarestays.com"].join(',')

  def user_feedback(user, type, message)
    @user = user
    @type = type
    @message = message

    mail(:subject => "User Feedback (#{type})")
  end

  # ==Description
  # Email sent when the user receives a message
  def new_message_admin(from_user, to_user, message)
    @from_user = from_user
    @to_user   = to_user
    @message   = message

    mail(:subject => "#{@to_user.full_name} has a new message!")
  end
end