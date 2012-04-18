class TransactionsController < ApiController
  protect_from_forgery :except => [:pay]

  # == Description
  # Applies an event to a transaction
  # ==Resource URL
  #   /transactions/:id.format
  # ==Example
  #   PUT https://backend-heypal.heroku.com/transactions/:id.json access_token=access_token event=request
  # === Parameters
  # [access_token]  Access token
  # === Error codes
  # [106] Record not found
  def update
    @inquiry = Inquiry.find(params[:id])
    @transaction = @inquiry.transaction

    if @transaction.change_state!(params[:event])
      return_message(200, :ok, :inquiry => {:id => @inquiry.id, :user_id => @inquiry.user_id, :state => @transaction.state, :code => @transaction.transaction_code})
     else
      return_message(200, :fail)
    end
  end

  def pay
    @transaction = Transaction.find_by_transaction_code(params[:code])

    if @transaction.received_payment!(params)
      return_message(200, :ok, :inquiry => {:state => @transaction.state})
     else
      return_message(200, :fail)
    end
  end

  # 
  # 
  # def preapprove_rental
  #   @inquiry = Inquiry.find(params[:id])
  #   @transaction = @inquiry.transaction
  #  
  #   if @transaction.process_payment!
  #     return_message(200, :ok, :inquiry => {:id => @inquiry.id, :user_id => @inquiry.user_id, :state => @transaction.state})
  #   else
  #     return_message(200, :fail)
  #   end
  # end

  # # == Description
  # # Cancels a transaction
  # # ==Resource URL
  # #   /places/:place_id/transactions/:id/cancel.format
  # # ==Example
  # #   GET https://backend-heypal.heroku.com/places/:place_id/transactions/:id/cancel.json access_token=access_token
  # # === Parameters
  # # [access_token]  Access token
  # # === Error codes
  # # [106] Record not found
  # # [138] already cancelled
  # def cancel
  #   place = Place.with_permissions_to(:read).find(params[:place_id])
  #   transaction = place.transactions.with_permissions_to(:cancel).find(params[:id])
  #   begin
  #     return_message(200, :ok) if transaction.cancel!
  #   rescue Exception => e
  #     # logger.error { "Error [transactions_controller.rb/cancel] #{e.message}" }
  #     return_message(200, :fail, :err => {:transaction => [138] })
  #   end
  # end
  # 
  # # == Description
  # # Starts payment of a transaction
  # # ==Resource URL
  # #   /places/:place_id/transactions/:id/pay.format
  # # ==Example
  # #   GET https://backend-heypal.heroku.com/places/:place_id/transactions/:id/pay.json access_token=access_token
  # # === Parameters
  # # [access_token]  Access token
  # # === Error codes
  # # [106] Record not found
  # def pay
  #   # get total to pay from transaction, send it to payment processor
  #   # TODO: authorize payment, ActiveMerchant?
  #   place = Place.with_permissions_to(:read).find(params[:place_id])
  #   transaction = place.transactions.with_permissions_to(:pay).find(params[:id])
  #   begin
  #     # do the payment thingy..
  #     return_message(200, :ok) if transaction.process_payment!
  #   rescue Exception => e
  #     # get error messages
  #     logger.error { "Error [transactions_controller.rb/pay] #{e.message}" }
  #     return_message(200, :fail)
  #   end
  # end
  # 
  # # == Description
  # # Process callback from payment processor
  # # ==Resource URL
  # #   /payment_processor_callback.format
  # # ==Example
  # #   GET https://backend-heypal.heroku.com/payment_processor_callback.json access_token=access_token
  # # === Parameters
  # # [access_token]  Access token
  # # === Error codes
  # def payment_processor_callback
  #   # TODO: search transaction with payment_token
  #   begin
  #     return_message(200, :ok) if transaction.confirm_payment!
  #   rescue Exception => e
  #     # get error messages
  #     return_message(200, :fail)
  #     logger.error { "Error [transactions_controller.rb/payment_processor_callback] #{e.message}" }
  #   end
  # end
  # 
  # # == Description
  # # Confirm rental
  # # ==Resource URL
  # #   /places/:place_id/transactions/:id/confirm.format
  # # ==Example
  # #   GET https://backend-heypal.heroku.com/places/:place_id/transactions/:id/confirm.json access_token=access_token
  # # === Parameters
  # # [access_token]  Access token
  # # === Error codes
  # # [106] Record not found
  # def confirm_rental
  #   place = Place.with_permissions_to(:manage).find(params[:place_id])
  #   transaction = place.transactions.with_permissions_to(:confirm_rental).find(params[:id])
  #   begin
  #     return_message(200, :ok) if transaction.confirm_rental!
  #   rescue Exception => e
  #     # get error messages
  #     logger.error { "Error [transactions_controller.rb/confirm_rental] #{e.message}" }
  #     return_message(200, :fail)
  #   end
  # end
  # 
  # # == Description
  # # Decline rental
  # # ==Resource URL
  # #   /places/:place_id/transactions/:id/decline.format
  # # ==Example
  # #   GET https://backend-heypal.heroku.com/places/:place_id/transactions/:id/decline.json access_token=access_token
  # # === Parameters
  # # [access_token]  Access token
  # # === Error codes
  # # [106] Record not found
  # def decline
  #   place = Place.with_permissions_to(:manage).find(params[:place_id])
  #   transaction = place.transactions.with_permissions_to(:decline).find(params[:id])
  #   begin
  #     return_message(200, :ok) if transaction.decline!
  #   rescue Exception => e
  #     # get error messages
  #     logger.error { "Error [transactions_controller.rb/decline] #{e.message}" }
  #     return_message(200, :fail)
  #   end
  # end

end