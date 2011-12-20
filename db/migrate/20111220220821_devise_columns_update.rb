class DeviseColumnsUpdate < ActiveRecord::Migration
  def change
    add_column :users, :unconfirmed_email, :string
    remove_column :users, :remember_token
  end
end