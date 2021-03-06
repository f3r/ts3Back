class PreviewMails < MailView

  ###############################################################
  # REGISTRATION_MAILER
  ###############################################################
  def confirmation_instructions
    user = User.first
    RegistrationMailer.confirmation_instructions(user)
  end

  def reset_password
    user = User.first
    RegistrationMailer.reset_password_instructions(user)
  end

  ###############################################################
  # USER_MAILER
  ###############################################################
  def signup_welcome
    user = User.first
    UserMailer.signup_welcome(user)
  end

  def auto_welcome
    user = User.first
    UserMailer.auto_welcome(user)
  end

  def new_message_reply
    user = User.first
    UserMailer.new_message_reply(user, Message.first)
  end

  ###############################################################
  # ALERT_MAILER
  ###############################################################
  def alert_mailer
    # TODO: Finish this up!
  end

  ###############################################################
  # INQUIRY_MAILER
  ###############################################################
  def inquiry_confirmed_renter
    InquiryMailer.inquiry_confirmed_renter(an_inquiry)
  end

  def inquiry_confirmed_owner
    InquiryMailer.inquiry_confirmed_owner(an_inquiry)
  end

  def inquiry_reminder_owner
    InquiryMailer.inquiry_reminder_owner(an_inquiry)
  end

  ###############################################################
  # TRANSACTION_MAILER
  ###############################################################
  def transaction_request_renter
    TransactionMailer.request_renter(an_inquiry)
  end

  def transaction_request_owner
    TransactionMailer.request_owner(an_inquiry)
  end

  def transaction_approve_renter
    TransactionMailer.approve_renter(an_inquiry)
  end

  def transaction_approve_owner
    TransactionMailer.approve_owner(an_inquiry)
  end

  def transaction_pay_renter
    TransactionMailer.pay_renter(an_inquiry)
  end

  def transaction_pay_owner
    TransactionMailer.pay_owner(an_inquiry)
  end

private

  def an_inquiry
    inquiry = Inquiry.new(
      :created_at => 2.days.ago,
      :place => Place.first,
      :user => User.first,
      :check_in => 1.month.from_now.to_date,
      :length_stay => 1,
      :length_stay_type => 'months',
      :extra => {
        :name => 'Consumer',
        :email => 'consumer@email.com'
      }
    )
  end
end