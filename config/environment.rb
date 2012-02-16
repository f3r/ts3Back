# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HeyPalBackEnd::Application.initialize!

HeyPalBackEnd::Application.configure do
  
  Paperclip::Attachment.default_options.merge!({
    :storage => APP_CONFIG['PAPER_STORAGE'] || :s3,
    :s3_protocol => 'http',
    :s3_credentials => {
      :access_key_id => S3_ACCESS_KEY_ID,
      :secret_access_key => S3_SECRET_ACCESS_KEY
    },
    :bucket => S3_BUCKET
  })

  # CarrierWave.configure do |config|
  #   config.storage = :fog
  #   if APP_CONFIG['STORAGE']
  #     config.storage = APP_CONFIG['STORAGE'].to_sym
  #   end
  # 
  #   if config.storage == CarrierWave::Storage::Fog
  #     config.fog_credentials = {
  #       :provider               => 'AWS',
  #       :aws_access_key_id      => S3_ACCESS_KEY_ID,
  #       :aws_secret_access_key  => S3_SECRET_ACCESS_KEY
  #     }
  #     config.fog_directory  = S3_BUCKET
  #   end
  # end

  config.after_initialize do
    ActionMailer::Base.default_url_options[:host] = FRONTEND_PATH
  end
end