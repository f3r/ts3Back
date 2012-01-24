class InquiryMailer < ActionMailer::Base  

  # ==Description
  # Temporary email sent when the user rents a place..
  def inquiry_confirmed_renter(place, params)
    begin
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

  def inquiry_confirmed_owner(place, params, check_in, check_out, current_user)
    begin
      @owner     = place.user
      if current_user
        @renter = current_user
      else
        @renter = User.new(:first_name => params[:name], :email => params[:email], :phone_mobile => params[:mobile])
      end

      @place     = place
      if check_in && check_out
        @check_in  = check_in
        @check_out = check_out
        @total_days = (check_in..check_out).to_a.count
      end

      recipient = "#{@owner.full_name} <#{@owner.email}>"
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

  def inquiry_confirmed_admin(place, params, check_in, check_out, current_user)
    begin
      @owner     = place.user
      if current_user
        @renter = current_user
      else
        @renter = User.new(:first_name => params[:name], :email => params[:email], :phone_mobile => params[:mobile])
      end
      @place     = place
      if check_in && check_out
        @check_in  = check_in
        @check_out = check_out
      end
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