class AddPassportNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :passport_number, :string
  end
end
