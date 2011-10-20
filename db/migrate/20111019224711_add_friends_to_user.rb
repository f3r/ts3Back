class AddFriendsToUser < ActiveRecord::Migration
  def change
    add_column :users, :friends, :string, :limit => 10000
  end
end
