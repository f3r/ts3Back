class PreviewMails < MailView
  def confirmation_instructions
    user = User.first
    RegistrationMailer.confirmation_instructions(user)
  end

  def reset_password
    user = User.first
    RegistrationMailer.reset_password_instructions(user)
  end

  def new_message
    user = User.first
    UserMailer.new_message(user, 1)
  end

  def inquiry_confirmed_renter
    InquiryMailer.inquiry_confirmed_renter(an_inquiry)
  end

  def inquiry_confirmed_owner
    InquiryMailer.inquiry_confirmed_owner(an_inquiry)
  end

  #def welcome
  #  user = User.first
  #  Devise::Mailer.welcome_instructions(user)
  #end

  private

  def an_inquiry
    inquiry = Inquiry.new(
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