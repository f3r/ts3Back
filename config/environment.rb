# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HeyPalBackEnd::Application.initialize!

HeyPalBackEnd::Application.configure do
  config.after_initialize do
    ActionMailer::Base.default_url_options[:host] = FRONTEND_PATH
  end
end