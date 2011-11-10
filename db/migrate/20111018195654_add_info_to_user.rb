class AddInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :users, :birthdate, :date
    add_column :users, :timezone, :string
    add_column :users, :phone_mobile, :string
    add_column :users, :avatar_file_name, :string
    add_column :users, :avatar_content_type, :string
    add_column :users, :avatar_file_size, :integer
    add_column :users, :avatar_updated_at, :datetime
    add_column :users, :pref_language, :string
    add_column :users, :pref_currency, :string
  end
end
