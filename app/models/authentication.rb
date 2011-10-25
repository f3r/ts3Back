class Authentication < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :provider, :scope => :user_id, :message => "100"
  validates_presence_of :user_id, :provider, :uid, :token, :message => "101"
  after_destroy :delete_cache

private

# Expires the cache when the authentication is deleted
def delete_cache
  Rails.cache.delete("user_#{self.user_id.to_s}_provider_#{self.provider}")
end

end