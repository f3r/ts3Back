class AddTransactionIdToAvailability < ActiveRecord::Migration
  def change
    add_column :availabilities, :transaction_id, :integer
    add_index :availabilities, :transaction_id
  end
end
