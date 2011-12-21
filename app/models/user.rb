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

  using_access_control

  before_save :ensure_authentication_token, :check_avatar_url
  after_save  :delete_cache

  attr_accessible :first_name,
                  :last_name,
                  :email, 
                  :gender, 
                  :birthdate, 
                  :timezone, 
                  :phone_mobile, 
                  :avatar, 
                  :avatar_url,
                  :password, 
                  :password_confirmation, 
                  :remember_me,
                  :pref_language,
                  :pref_currency,
                  :pref_size_unit,
                  :role,
                  :passport_number

  attr_accessor :avatar_url

  with_options :if => :password_validations_required? do |p|
    p.validates_presence_of     :password,                   :message => "101"
    p.validates_presence_of     :password_confirmation,      :message => "101"
    p.validates_length_of       :password, :within => 6..40, :message => "102"
    p.validates_confirmation_of :password,                   :message => "104"
  end

  validates_presence_of   :email, :message => "101"
  validates_uniqueness_of :email, :message => "100"
  validates_format_of     :email, :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, :message => "103"
  validates_inclusion_of  :role, :in => ["superadmin", "admin", "agent", "user"], :message => "103"
  validates_inclusion_of  :pref_size_unit, :in => ["sqm", "sqf"], :allow_blank => true, :message => "103"

  validates_date :birthdate, 
    :invalid_date_message => "113", 
    :on => :update, 
    :unless => lambda { (self.password && self.password_confirmation) or role_changed? },
    :before => lambda { Date.current },
    :allow_nil => true

  has_many :authentications, :dependent => :destroy
  has_many :addresses,       :dependent => :destroy
  has_many :places,          :dependent => :destroy
  # TODO: Do we really want to destroy comments or nullify them?
  has_many :comments,        :dependent => :destroy
  has_many :transactions
  
  has_attached_file :avatar, 
     :styles => {
       :thumb  => "100x100#",
       :medium => "300x300#",
       :large  => "600x600>" },
     :storage => :s3,
     :s3_protocol => 'https',
     :s3_credentials => {
       :access_key_id => S3_ACCESS_KEY_ID,
       :secret_access_key => S3_SECRET_ACCESS_KEY
     },
     :bucket => S3_BUCKET,
     :path => "avatars/:id_partition/:style.:extension",
     :default_url => "none",
     :convert_options => { 
       :large => "-quality 80", 
       :medium => "-quality 80", 
       :thumb => "-quality 80" }


  def role_symbols
    [role.to_sym]
  end

  def has_role?(the_role)
    role == the_role.to_s
  end

  def password_validations_required?
    encrypted_password.blank? or (password && password_confirmation) or encrypted_password_changed?
  end

  def full_name
    [first_name,last_name].join(' ')
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end
  
  def activated?
    !self.confirmed_at.blank?
  end

  # Returns true if the current user is friends with the given user
  def friends?(user)
    REDIS.sismember(self.redis_key(:friend), user.facebook.uid)
  end
  
  # Returns true if the current user and the given user have a common friend
  def fof?(user)
    REDIS.sinter(self.redis_key(:friend), user.redis_key(:friend))
  end
    
  # helper method to generate redis keys
  def redis_key(str)
    "user:#{self.id}:#{str}"
  end

  def facebook_info(auto_import=false)
    authentication = self.authentications.where(:provider => "facebook").first
    if authentication && authentication.token
      begin
        client   = OAuth2::Client.new(FB_APP_ID, FB_APP_SECRET, :site => "https://graph.facebook.com")
        facebook = OAuth2::AccessToken.new(client, authentication.token)
        info     = JSON.parse(facebook.get("/#{authentication.uid}"))
        birthday = Date.strptime(info['birthday'], "%m/%d/%Y") if info['birthday'] rescue nil
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
        logger.error { "Error [user.rb/facebook_info] #{e.message}" }
        return nil
      end
    else
      return nil
    end
  end
  
  # gets users facebook authentication object, if exists
  def facebook
    Rails.cache.fetch("user_#{self.id.to_s}_provider_facebook") { self.authentications.find_by_provider("facebook") }
  end
  
  # gets users twitter authentication object, if exists
  def twitter
    Rails.cache.fetch("user_#{self.id.to_s}_provider_twitter") { self.authentications.find_by_provider("twitter") }
  end
  
  private  

  # Expires the cache when the user info is updated
  def delete_cache
    delete_caches(["user_info_" + self.id.to_s, "user_" + self.id.to_s])
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
        logger.error { "Error [user.rb/check_avatar_url] #{e.message}" }
        return nil
      end
    end
  end

end