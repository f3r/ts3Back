class RentalMailer < ActionMailer::Base  
  default :from     => 'Heypal.com <support@heypal.com>',
          :reply_to =>  'Heypal.com <support@heypal.com>'

# ==Description
# Temporary email sent when the user rents a place..
def rental_confirmed(owner, renter, place, check_in, check_out)
  begin
    @owner        = owner
    @renter       = renter
    @place        = place
    @check_in     = check_in
    @check_out    = check_out
    recipients = "#{user.full_name} <#{user.email}>, #{renter.full_name} <#{renter.email}>, Heypal.com <support@heypal.com>"
    subject    = 'Confirmed rental!'
    sent_on    =  Time.now
    mail(:to => recipients, :subject => subject, :date => sent_on) do |format|
      format.text
      # format.html
    end
  rescue Exception => e
    logger.error { "Error [rental_mailer.rb/rental_confirmed] #{e.message}" }
  end
end

end