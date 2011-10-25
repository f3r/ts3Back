class User < ActiveRecord::Base
  include GeneralHelper
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, # Encrypting Password and validating authenticity of user
         :registerable,             # Users can sign up :)
         :recoverable,              # Reset user password
         :rememberable,             # Generating/Clearing token for remember user from cookie
         :trackable,                # Tracks:
                                    #   * sign_in_count      - Increased every time a sign in is made (by form, openid, oauth)
                                    #   * current_sign_in_at - A tiemstamp updated when the user signs in
                                    #   * last_sign_in_at    - Holds the timestamp of the previous sign in
                                    #   * current_sign_in_ip - The remote ip updated when the user sign in
                                    #   * last_sign_in_ip    - Holds the remote ip of the previous sign in
         :validatable,              # Email/Pwd validation
         :confirmable,              # Verify account already confirmed, send email with instructions
         # :encryptable,            # Encrypts Password (bcript)
         # :invitable,              # Send invites: https://github.com/scambra/devise_invitable
         :token_authenticatable     # Generate auth token and validates it

  # Setup accessible (or protected) attributes for your model

  before_save :ensure_authentication_token, :check_avatar_url
  after_save :delete_cache

  attr_accessible :first_name,
                  :last_name,
                  :email, 
                  :gender, 
                  :birthdate, 
                  :timezone, 
                  :phone_home, 
                  :phone_mobile, 
                  :phone_work, 
                  :avatar, 
                  :avatar_url,
                  :password, 
                  :password_confirmation, 
                  :remember_me,
                  :friends

  attr_accessor :avatar_url

  serialize :friends

  with_options :if => :password_validations_required? do |p|
    p.validates_presence_of :password, :message => "101"
    p.validates_presence_of :password_confirmation, :message => "101"
    p.validates_length_of :password, :within => 6..40, :message => "102"
    p.validates_confirmation_of :password, :message => "104"
  end

  validates_presence_of :email, :message => "101"
  validates_uniqueness_of :email, :message => "100"
  validates_format_of :email, :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, :message => "103"

  validates_date :birthdate, 
    :invalid_date_message => "113", 
    :on => :update, 
    :before => lambda { Date.current } 

  has_many :authentications, :dependent => :destroy
  has_many :addresses, :dependent => :destroy
  
  has_attached_file :avatar, 
     :styles => {
       :thumb  => "100x100#",
       :medium => "300x300#",
       :large  => "600x600>" },
     :storage => :s3,
     :s3_protocol => 'https',
     :s3_credentials => "#{Rails.root}/config/s3.yml",
     :path => "avatars/:id_partition/:style.:extension",
     :default_url => "none",
     :convert_options => { 
       :large => "-quality 80", 
       :medium => "-quality 80", 
       :thumb => "-quality 80" }

  def password_validations_required?
    encrypted_password.blank?
  end

  def full_name
    [first_name,last_name].join(' ')
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - (birthdate.to_date.change(:year => now.year) > now ? 1 : 0)
  end

  def import_facebook_friends  
    begin
      authentication = self.authentications.where(:provider => "facebook").first
      if authentication
        # CHANGED: Moved appId, SecretID, etc to config/environments/*.rb
        client   = OAuth2::Client.new(FB[:app_id], FB[:app_secret], :site => FB[:app_url])
        facebook = OAuth2::AccessToken.new(client, authentication.token)
        info     = JSON.parse(facebook.get('/me/friends'))
        if info
          # Update the REDIS information: delete all and create one by one... sigh
          REDIS.multi do
            REDIS.del(self.redis_key(:friend))
            info['data'].each { |friend|
               REDIS.sadd(self.redis_key(:friend), friend['id'])
            }
          end
        end
      end
    rescue Exception => e
      return e
    end
  end

  # Returns true if the current user is friends with the given user
  def friends?(user)
    REDIS.sismember(self.redis_key(:friend), user.id)
  end
  
  # Returns true if the current user and the given user have a common friend
  def fof?(user)
    REDIS.sinter(self.redis_key(:friend), user.redis_key(:friends))
  end
    
  # helper method to generate redis keys
  def redis_key(str)
    "user:#{self.id}:#{str}"
  end

  def facebook_info(auto_import=false)
    begin
      authentication = self.authentications.where(:provider => "facebook").first
      client = OAuth2::Client.new(FB[:app_id], FB[:app_secret], :site => 'https://graph.facebook.com')
      facebook = OAuth2::AccessToken.new(client, authentication.token)
      info = JSON.parse(facebook.get("/#{authentication.uid}"))
      birthday = Date.strptime(info['birthday'], "%m/%d/%Y")
      info = {
        :first_name => info['first_name'],
        :last_name => info['last_name'],
        :gender => info['gender'],
        :birthdate => birthday,
        :avatar_url => "http://graph.facebook.com/" + info['id'] + "/picture?type=large"
      }
      self.update_attributes(info) if auto_import
      return info
    rescue Exception => e
      return nil
    end
  end
  
  private  

  # Expires the cache when the user info is updated
  def delete_cache
    delete_caches(["user_info_" + self.id.to_s, "user_full_info_" + self.id.to_s])
  end
  
  # checks if avatar_url is set and updates the avatar if avatar_url is an image
  def check_avatar_url
    if self.avatar_url
      begin
        remote_avatar = open(self.avatar_url)
        if remote_avatar.content_type.match(/image/)
          self.avatar = remote_avatar
        end
      rescue Exception => e
        return nil
      end
    end
  end

end