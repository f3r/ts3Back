# LOAD LOCAL CONFIGURATION
if Rails.env.test? or Rails.env.development?
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/local.yml")[Rails.env]
else
  APP_CONFIG = {}
end

# SET VARIABLES, DEVELOPMENT, TEST FALLBACKS
S3_ACCESS_KEY_ID =      ENV['S3_ACCESS_KEY_ID']       || APP_CONFIG['S3_ACCESS_KEY_ID']
S3_SECRET_ACCESS_KEY =  ENV['S3_SECRET_ACCESS_KEY']   || APP_CONFIG['S3_SECRET_ACCESS_KEY']
S3_BUCKET =             ENV['S3_BUCKET']              || APP_CONFIG['S3_BUCKET']
FB_APP_ID =             ENV['FB_APP_ID']              || APP_CONFIG['FB_APP_ID']
FB_APP_SECRET =         ENV['FB_APP_SECRET']          || APP_CONFIG['FB_APP_SECRET']
FRONTEND_PATH =         ENV['FRONTEND_PATH']          || APP_CONFIG['FRONTEND_PATH']
SECRET_TOKEN =          ENV['SECRET_TOKEN']           || APP_CONFIG['SECRET_TOKEN']
COOKIE_STORE_KEY =      ENV['COOKIE_STORE_KEY']       || APP_CONFIG['COOKIE_STORE_KEY']
REDISTOGO_URL =         ENV['REDISTOGO_URL']          || APP_CONFIG['REDISTOGO_URL']
MAILER_SENDER =         ENV['MAILER_SENDER']          || APP_CONFIG['MAILER_SENDER']
PEPPER_TOKEN =          ENV['PEPPER_TOKEN']           || APP_CONFIG['PEPPER_TOKEN']
SITE_NAME =             ENV['SITE_NAME']              || APP_CONFIG['SITE_NAME']
SUPPORT_EMAIL =         ENV['SUPPORT_EMAIL']          || APP_CONFIG['SUPPORT_EMAIL']
RAKISMET_KEY =          ENV['RAKISMET_KEY']           || APP_CONFIG['RAKISMET_KEY']
RAKISMET_URL =          ENV['RAKISMET_URL']           || APP_CONFIG['RAKISMET_URL']