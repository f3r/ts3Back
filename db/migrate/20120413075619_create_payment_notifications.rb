class CreatePaymentNotifications < ActiveRecord::Migration
  def change
    create_table :payment_notifications do |t|
      t.integer :user_id
      t.text :params
      t.string :status
      t.string :txn_id

      t.integer :transaction_id
      t.timestamps
    end
  end
end
