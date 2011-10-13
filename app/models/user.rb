class User < ActiveRecord::Base
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

  attr_accessible :email, :password, :password_confirmation, :remember_me

  with_options :if => :email_validations_required? do |p|
    p.validates_presence_of :email    
    p.validates_format_of :email, :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

  with_options :if => :password_validations_required? do |p|
    p.validates_presence_of :password
    p.validates_presence_of :password_confirmation
    p.validates_length_of :password, :within => 6..40
    p.validates_confirmation_of :password
  end
  
  has_many :authentications, :dependent => :destroy

  def password_validations_required?
    # encrypted_password.blank?
    true
  end

  def email_validations_required?
    true
  end
  
  def self.find_for_facebook_oauth(token, user=nil)
  end

  def self.find_for_twitter_oauth(token=nil, user=nil)
    if user && token['credentials']
      authentication = user.authentications.find_or_create_by_provider_and_uid_and_oauth_token_and_oauth_token_secret(:provider => "twitter", :uid => token['uid'], :oauth_token => token['credentials']['token'], :oauth_token_secret => token['credentials']['secret'])
    elsif token['credentials']
      authentication = Authentication.find_by_provider_and_uid("twitter", token['uid'])
    end
    return authentication.user if authentication
  end

end