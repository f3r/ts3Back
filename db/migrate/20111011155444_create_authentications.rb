class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.string :oauth_token_secret

      t.timestamps
    end
    add_index :authentications, :user_id
    add_index :authentications, :provider
  end
end
