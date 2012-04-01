class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.references :user
      t.string :alert_type
      t.text :query
      t.text :results
      t.string :delivery_method, :default => "email"
      t.string :schedule, :default => "daily"
      t.boolean :active, :default => true
      t.string :search_code
      t.datetime :delivered_at
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :alerts, :user_id
  end
end