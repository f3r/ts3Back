class User < ActiveRecord::Base
  has_many :addresses
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
         # :encryptable,              # Encrypts Password (bcript)
         # :invitable,                # Send invites: https://github.com/scambra/devise_invitable
         :token_authenticatable     # Generate auth token and validates it

  # Setup accessible (or protected) attributes for your model

  before_save :ensure_authentication_token

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  with_options :if => :email_validations_required? do |p|
    p.validates_presence_of :email, :message => 101
    p.validates_uniqueness_of :email, :message => 100
    p.validates_format_of :email, :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, :message => 103
  end

  with_options :if => :password_validations_required? do |p|
    p.validates_presence_of :password, :message => 101
    p.validates_presence_of :password_confirmation, :message => 101
    p.validates_length_of :password, :within => 6..40, :message => 102
    p.validates_confirmation_of :password, :message => 104
  end
  
  has_many :authentications, :dependent => :destroy

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
    # encrypted_password.blank?
    true
  end

  def email_validations_required?
    true
  end

  def self.find_for_oauth(token, user=nil)
    if user && token['credentials']
      authentication = user.authentications.find_or_create_by_provider_and_uid_and_oauth_token_and_oauth_token_secret(
        :provider => token['provider'], 
        :uid => token['uid'], 
        :token => token['credentials']['token'], 
        :secret => token['credentials']['secret'])
    elsif token['credentials']
      authentication = Authentication.find_by_provider_and_uid(token['provider'], token['uid'])
    end
    return authentication.user if authentication
  end

end