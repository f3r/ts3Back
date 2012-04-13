class PaymentNotificationsController < ApplicationController
  protect_from_forgery :except => [:create]

  def create
    PaymentNotification.create!(:params => params, :transaction_id => params[:invoice], :status => params[:payment_status], :txn_id => params[:txn_id] )
    render :nothing => true
  end
end
