class InquiryMailer < BaseMailer

  # ==Description
  # Email sent to the renter when the user inquires about a place
  def inquiry_confirmed_renter(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @user      = inquiry.user
    recipient  = "#{@user.full_name} <#{@user.email}>"
    subject    = t('inquiries.confirmed_renter_subject')

    mail(:to => recipient, :subject => subject)
  end

  # ==Description
  # Email sent to the owner when the user inquires about a place
  def inquiry_confirmed_owner(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @renter    = inquiry.user

    recipient  = "#{@owner.full_name} <#{@owner.email}>"
    subject    = t('inquiries.confirmed_owner_subject')

    mail(:to => recipient, :subject => subject)
  end

  def inquiry_spam(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @renter      = inquiry.user

    recipient = "#{@owner.full_name} <#{@owner.email}>"
    subject   = t('inquiries.received_spam_subject')

    mail(:to => recipient, :subject => subject)
  end

  # Email sent to the owner to remind abount an inquiry that hasn't been replied
  def inquiry_reminder_owner(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @renter    = inquiry.user

    recipient  = "#{@owner.full_name} <#{@owner.email}>"
    subject    = t('inquiries.reminder_owner_subject')

    mail(:to => recipient, :subject => subject)
  end
end