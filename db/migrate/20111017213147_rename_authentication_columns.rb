class RenameAuthenticationColumns < ActiveRecord::Migration
  def change
    rename_column :authentications, :oauth_token, :token
    rename_column :authentications, :oauth_token_secret, :secret
  end
end
