class UserMailer < ActionMailer::Base
  layout 'user_email'
  add_template_helper(FrontendHelper)
  default :from => MAILER_SENDER

  # ==Description
  # Email sent when the user signups for an account
  def signup_welcome(user)
    @user      = user
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = 'Welcome to SquareStays'

    mail(:to => recipients, :subject => subject)
  end

  # ==Description
  # Email sent when we create an user account automatically
  def auto_welcome(user)
    @user      = user
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = 'Welcome to SquareStays'

    mail(:to => recipients, :subject => subject)
  end

  # ==Description
  # Email sent when the user receives a message
  def new_message_reply(user, message)
    @user      = user
    # @conversation = message.conversation
    @message   = message
    from = @message.from

    recipients = "#{user.full_name} <#{user.email}>"
    subject    = "You have a new message from #{from.anonymized_name} on SquareStays.com!"

    mail(:to      => recipients, :subject => subject)
  end
end