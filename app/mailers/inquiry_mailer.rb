class InquiryMailer < ActionMailer::Base
  add_template_helper(FrontendHelper)

  # ==Description
  # Email sent when the user inquires about a place..
  def inquiry_confirmed_renter(inquiry)
    @inquiry       = inquiry
    @place         = inquiry.place
    @owner         = @place.user
    # TODO: use inquiry.user
    @name          = inquiry.extra[:name]
    @email         = inquiry.extra[:email]

    recipient = "#{@name} <#{@email}>"
    subject    = "Your Inquiry on SquareStays has been sent"
    mail(:from    => MAILER_SENDER,
         :to      => recipient,
         :subject => subject) do |format|
      #format.text
      format.html { render :layout => 'user_email' }
    end
  end

  def inquiry_confirmed_owner(inquiry)
    @inquiry   = inquiry
    @place     = inquiry.place
    @owner     = @place.user
    @name      = inquiry.extra[:name]
    @email     = inquiry.extra[:email]
    @mobile    = inquiry.extra[:mobile]
    @call_me   = inquiry.extra[:call_me]
    @questions = inquiry.message

    if inquiry.user
      @renter = inquiry.user
    else
      @renter = User.new(:first_name => params[:name], :email => params[:email], :phone_mobile => params[:mobile])
    end

    recipient = "#{@owner.full_name} <#{@owner.email}>"
    subject    = "You have received an inquiry on SquareStays"
    mail(:from    => MAILER_SENDER,
         :to      => recipient,
         :subject => subject) do |format|
      #format.text
      format.html { render :layout => 'user_email' }
    end
  end

  def inquiry_confirmed_admin(place, params, check_in, check_out, current_user, inquiry = nil)
    @owner     = place.user
    if current_user
      @renter = current_user
    else
      @renter = User.new(:first_name => params[:name], :email => params[:email], :phone_mobile => params[:mobile])
    end
    @place     = place
    @inquiry   = inquiry
    if check_in && check_out
      @check_in  = check_in
      @check_out = check_out
    end
    recipients = ["jeremy@squarestays.com", "fer@squarestays.com"].join(',')
    subject    = "Inquiry request"
    mail(:from    => MAILER_SENDER,
         :to      => recipients,
         :subject => subject) do |format|
      format.html
    end
  end
end