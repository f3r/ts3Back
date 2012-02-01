class Authentication < ActiveRecord::Base
  using_access_control
  belongs_to :user
  validates_uniqueness_of :provider, :scope => :user_id, :message => "100"
  validates_presence_of :user_id, :provider, :uid, :token, :message => "101"
  after_destroy :delete_cache

private

  # Returns an authentication for a given provider and token
  def self.check_and_update(provider, token)
    auth = Authentication.find_by_provider_and_token(provider, token)
    
    if !auth && provider == 'facebook'
      # Since we dont require offline access facebook tokens change frequently
      # We need to refresh the 
      auth = self.update_facebook_token(token)
    end
    
    auth
  end
  
  # Checks if a user was already authenticated with an older token and updates it 
  def self.update_facebook_token(token)
    begin
      client = OAuth2::Client.new(FB_APP_ID, FB_APP_SECRET, :site => "https://graph.facebook.com")
      facebook = OAuth2::AccessToken.new(client, token)
      info = JSON.parse(facebook.get("/me"))
      auth = Authentication.find_by_provider_and_uid('facebook', info['id'])
      return unless auth
      
      without_access_control do
        auth.update_attribute(:token, token)
      end
      
      return auth
    rescue Exception => e
      logger.error { "Error [user.rb/facebook_info] #{e.message}" }
      return nil
    end
  end
  
  # Expires the cache when the authentication is deleted
  def delete_cache
    Rails.cache.delete("user_#{self.user_id.to_s}_provider_#{self.provider}") 
  end

end