class TransactionsController < ApplicationController
  filter_access_to :all, :attribute_check => false
  respond_to :xml, :json

  # == Description
  # Cancels a transaction
  # ==Resource URL
  #   /places/:place_id/transactions/:id/cancel.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/places/:place_id/transactions/:id/cancel.json access_token=access_token
  # === Parameters
  # [access_token]  Access token
  # === Error codes
  # [106] Record not found
  def cancel
    place = Place.find(params[:place_id])
    transaction = place.transactions.find(params[:id])
    begin
      return_message(200, :ok) if transaction.cancel!
    rescue Exception => e
      return_message(200, :fail)
      logger.error { "Error [transactions_controller.rb/cancel] #{e.message}" }
    end
  end

end