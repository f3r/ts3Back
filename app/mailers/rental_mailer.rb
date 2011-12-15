class RentalMailer < ActionMailer::Base  

  # ==Description
  # Temporary email sent when the user rents a place..
  def rental_confirmed_renter(owner, renter, place, check_in, check_out)
    begin
      @owner     = owner
      @renter    = renter
      @place     = place
      @check_in  = check_in
      @check_out = check_out
      # recipient = "#{renter.full_name} <#{renter.email}>"
      recipient = "jorge@heypal.com"
      subject    = "Your Request for rental has been sent"
      mail(:from    => MAILER_SENDER,
           :to     => recipient, 
           :subject => subject) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [rental_mailer.rb/rental_confirmed_renter] #{e.message}" }
    end
  end

  def rental_confirmed_owner(owner, renter, place, check_in, check_out)
    begin
      @owner     = owner
      @renter    = renter
      @place     = place
      @check_in  = check_in
      @check_out = check_out
      @total_days = (check_out.to_date - check_in.to_date).to_i
      # recipient = "#{owner.full_name} <#{owner.email}>"
      recipient = "jorge@heypal.com"
      subject    = "You have received a rental request"
      mail(:from    => MAILER_SENDER,
           :to     => recipient, 
           :subject => subject) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [rental_mailer.rb/rental_confirmed_owner] #{e.message}" }
    end
  end

  def rental_confirmed_admin(owner, renter, place, check_in, check_out)
    begin
      @owner     = owner
      @renter    = renter
      @place     = place
      @check_in  = check_in
      @check_out = check_out
      # recipients = ["jeremy@squarestays.com", "fer@squarestays.com"]
      recipients = "jorge@heypal.com"
      subject    = "Rental request"
      mail(:from    => MAILER_SENDER,
           :bcc     => recipients, 
           :subject => subject) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [rental_mailer.rb/rental_confirmed_admin] #{e.message}" }
    end
  end
end