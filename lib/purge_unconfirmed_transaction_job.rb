class PurgeUnconfirmedTransactionJob < Struct.new(:transaction_id)
  def perform
    Transaction.purge_unconfirmed_transaction(transaction_id)
  end
end