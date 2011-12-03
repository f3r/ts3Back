class AddTransactionCodeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :transaction_code, :string
  end
end