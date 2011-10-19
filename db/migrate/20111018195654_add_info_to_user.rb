class AddInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :users, :birthdate, :date
    add_column :users, :timezone, :string
    add_column :users, :phone_home, :string
    add_column :users, :phone_mobile, :string
    add_column :users, :phone_work, :string
    add_column :users, :avatar_file_name, :string
    add_column :users, :avatar_content_type, :string
    add_column :users, :avatar_file_size, :integer
    add_column :users, :avatar_updated_at, :datetime
  end
end
