class PaymentNotification < ActiveRecord::Base

private
  def mark_cart_as_paid
    if status == "Completed"
      transaction.confirm_payment!
    end
  end
end
