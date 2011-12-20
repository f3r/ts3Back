source 'http://rubygems.org'

gem 'rails', '3.1.2'
gem 'rack', '1.3.5'

gem 'devise', '2.0.0.rc'          # Account Management
gem 'oauth2', '0.4.1'             # oAuth providers management
gem 'paperclip', "~> 2.4"         # Attachements
gem 'aws-s3'                      # Upload to Amazon S3
gem 'money'                       # Currency management
gem 'google_currency'             # Currency Exchange conversion
gem 'mysql2', '0.3.11'            # MySQL DB
gem 'redis'                       # Redis NoSQL DB
gem 'dalli'                       # Memcached
gem 'delayed_job'                 # Background Jobs
gem 'will_paginate'               # Paginating results
gem 'ransack'                     # Object-based search
gem 'geocoder'                    # Geocoding Google-based
gem 'declarative_authorization'   # Access Control List
gem 'workflow'                    # State control
gem 'heroku_san'                  # Manages multiple production environments
gem 'validates_timeliness', '~> 3.0.2'

group :development do
 gem 'hirb'              # Console on Steroids :) https://github.com/cldwalker/hirb
end

group :test do
  gem 'turn', :require => false  # Pretty printed test output
  gem 'shoulda'
  gem "shoulda-matchers"
  gem 'factory_girl'
  gem 'faker'
  gem 'minitest'
end

group :production do
  gem 'rack-ssl-enforcer'
end