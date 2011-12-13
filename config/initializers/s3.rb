if ENV['RACK_ENV'] == "staging" || ENV['RACK_ENV'] == "production"
  # set credentials from ENV hash
  S3_CREDENTIALS = { 
    :access_key_id     => ENV['S3_ACCESS_KEY_ID'], 
    :secret_access_key => ENV['S3_SECRET_ACCESS_KEY'], 
    :bucket            => ENV['S3_BUCKET']
  }
else
  # get credentials from YML file
  S3_CREDENTIALS = Rails.root.join("config/s3.yml")
end