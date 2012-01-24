class InquiryMailer < ActionMailer::Base  

  # ==Description
  # Temporary email sent when the user rents a place..
  def inquiry_confirmed_renter(place, params)
    begin
      logger.error { "*"*80 }
      logger.error { params.inspect }
      logger.error { "*"*80 }
      @place         = place
      @owner         = place.user
      @name          = params['name']
      @email         = params['email']
      @mobile        = params['mobile']
      @call_me       = params['call_me']
      @date_start    = params['date_start']
      @length_stay   = params['length_stay']
      @length_stay2  = params['length_stay_type']
      @questions     = params['questions']
      
      recipient = "#{@name} <#{@email}>"
      subject    = "Your Inquiry  has been sent"
      mail(:from    => MAILER_SENDER,
           :to      => recipient, 
           :subject => subject) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [inquiry_mailer.rb/inquiry_confirmed_renter] #{e.message}" }
    end
  end

  def inquiry_confirmed_owner(owner, renter, place, check_in, check_out)
    begin
      @owner     = owner
      @renter    = renter
      @place     = place
      @check_in  = check_in
      @check_out = check_out
      @total_days = (check_out.to_date - check_in.to_date).to_i
      recipient = "#{owner.full_name} <#{owner.email}>"
      subject    = "You have received an inquiry request"
      mail(:from    => MAILER_SENDER,
           :to      => recipient, 
           :subject => subject) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [inquiry_mailer.rb/inquiry_confirmed_owner] #{e.message}" }
    end
  end

  def inquiry_confirmed_admin(owner, renter, place, check_in, check_out)
    begin
      @owner     = owner
      @renter    = renter
      @place     = place
      @check_in  = check_in
      @check_out = check_out
      recipients = ["jeremy@squarestays.com", "fer@squarestays.com"].join(',')
      subject    = "Inquiry request"
      mail(:from    => MAILER_SENDER,
           :to      => recipients, 
           :subject => subject) do |format|
        format.text
        format.html
      end
    rescue Exception => e
      logger.error { "Error [inquiry_mailer.rb/inquiry_confirmed_admin] #{e.message}" }
    end
  end
end