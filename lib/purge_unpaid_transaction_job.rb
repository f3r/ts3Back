class PurgeUnpaidTransactionJob < Struct.new(:transaction_id)
  def perform
    Transaction.purge_unpaid_transaction(transaction_id)
  end
end