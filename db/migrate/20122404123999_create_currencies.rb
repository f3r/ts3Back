class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :symbol
      t.string :country
      t.string :currency_code
      t.boolean:active, :default => false
    end
  end
end
