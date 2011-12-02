class CreateTransactionLogs < ActiveRecord::Migration
  def change
    create_table :transaction_logs do |t|
      t.references :transaction
      t.string :state
      t.string :previous_state
      t.text :additional_data # serialized

      t.timestamps
    end
    add_index :transaction_logs, :transaction_id
  end
end
