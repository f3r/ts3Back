class RentalMailer < ActionMailer::Base  

# ==Description
# Temporary email sent when the user rents a place..
def rental_confirmed(owner, renter, place, check_in, check_out)
  begin
    @owner     = owner
    @renter    = renter
    @place     = place
    @check_in  = check_in
    @check_out = check_out
    recipients = ["#{owner.full_name} <#{owner.email}>" , "#{renter.full_name} <#{renter.email}>", "SquareStays.com <jeremy@squarestays.com>"]
    subject    = 'Confirmed rental!'
    sent_on    =  Time.now
    mail(:from    => 'noreply@squarestays.com',
         :bcc     => recipients, 
         :subject => subject,
         :date    => sent_on) do |format|
      format.text
      # format.html
    end
  rescue Exception => e
    logger.error { "Error [rental_mailer.rb/rental_confirmed] #{e.message}" }
  end
end

end