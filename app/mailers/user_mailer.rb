class UserMailer < BaseMailer

  # ==Description
  # Email sent when the user signups for an account
  def signup_welcome(user)
    @user      = user
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = t('devise.registrations.signed_up')

    mail(:to => recipients, :subject => subject)
  end

  # ==Description
  # Email sent when we create an user account automatically (from an inquiry)
  def auto_welcome(user)
    @user      = user
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = t('devise.registrations.signed_up')

    mail(:to => recipients, :subject => subject)
  end

  # ==Description
  # Email sent when the user receives a message
  def new_message_reply(user, message)
    @user      = user
    @message   = message
    from       = @message.from
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = t('messages.new_reply_subject', :sender => from.anonymized_name)

    mail(:to => recipients, :subject => subject)
  end
end