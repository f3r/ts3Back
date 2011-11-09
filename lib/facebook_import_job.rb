class FacebookImport < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    authentication = user.authentications.where(:provider => "facebook").first
    if authentication
      client   = OAuth2::Client.new(FB[:app_id], FB[:app_secret], :site => FB[:app_url])
      facebook = OAuth2::AccessToken.new(client, authentication.token)
      friends  = JSON.parse(facebook.get('/me/friends'))
      if friends
        # Update the REDIS information: delete all and create one by one... sigh
        REDIS.multi do
          REDIS.del(user.redis_key(:friend))
          friends['data'].each { |friend|
            REDIS.sadd(user.redis_key(:friend), friend['id'])
          }
        end
      end
    end
  end
end