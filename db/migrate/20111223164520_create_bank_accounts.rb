class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.references :user
      t.string :holder_name
      t.string :holder_street
      t.string :holder_zip
      t.string :holder_state_name
      t.string :holder_city_name
      t.string :holder_country_name
      t.string :holder_country_code
      t.string :account_number
      t.string :bank_code
      t.string :branch_code
      t.string :iban
      t.string :swift
      t.timestamps
    end
  end
end
