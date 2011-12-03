class PurgeTemporaryReservationJob < Struct.new(:transaction, :availability)
  def perform
    Transaction.purge_temporary_reservation(transaction,availability)
  end
end