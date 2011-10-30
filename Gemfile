source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'rack', '1.3.3'
gem 'mysql2'
gem 'devise', "1.4.7"
gem 'oauth2', "0.4.1"
gem "paperclip", "~> 2.4"
gem "aws-s3"
gem 'jquery-rails'
gem 'validates_timeliness', '~> 3.0.2'
gem 'redis'
gem 'money'
gem 'google_currency'

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'shoulda'
  gem "shoulda-matchers"
  gem 'factory_girl'
  gem 'faker'
  gem 'minitest'
end

group :production do
  gem 'rack-ssl-enforcer'
  gem 'dalli'               # Memcached
end