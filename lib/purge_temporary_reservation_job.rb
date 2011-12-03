class PurgeTemporaryReservationJob < Struct.new(:transaction_id)
  def perform
    Transaction.purge_temporary_reservation(transaction_id)
  end
end