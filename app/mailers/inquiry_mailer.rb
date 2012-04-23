class InquiryMailer < BaseMailer 

  # ==Description
  # Email sent to the renter when the user inquires about a place
  def inquiry_confirmed_renter(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @user      = inquiry.user
    recipient  = "#{@user.full_name} <#{@user.email}>"
    subject    = "Your Inquiry on SquareStays has been sent"
    
    mail(:to => recipient, :subject => subject)
  end

  # ==Description
  # Email sent to the owner when the user inquires about a place
  def inquiry_confirmed_owner(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @renter    = inquiry.user ? inquiry.user : User.new(:first_name => params[:name], :email => params[:email], :phone_mobile => params[:mobile])
  
    recipient = "#{@owner.full_name} <#{@owner.email}>"
    subject    = "You have received an inquiry on SquareStays"
    
    mail(:to => recipient, :subject => subject)
  end
  
  def inquiry_spam(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @renter      = inquiry.user
    
    recipient = "#{@owner.full_name} <#{@owner.email}>"
    subject = "You have received a spam inquiry on SquareStays"
    
    mail(:to => recipient, :subject => subject)
    
  end

end