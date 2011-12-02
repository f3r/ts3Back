class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|

      t.references :user
      t.references :place
      t.string :state, :default => "bigbang"
      t.date :check_in
      t.date :check_out
      t.string :currency
      t.float :price_per_night
      t.float :price_final_cleanup
      t.float :price_security_deposit
      t.float :service_fee
      t.float :service_percentage
      t.float :sub_total
      t.text :additional_data # serialized

      t.timestamps
    end
    add_index :transactions, :user_id
    add_index :transactions, :place_id
    add_index :transactions, :state
  end
end