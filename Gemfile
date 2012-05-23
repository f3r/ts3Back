source 'http://rubygems.org'

gem 'rails', '3.2.1'
# gem 'rack', '1.3.5'

gem 'devise', '2.0.0.rc'          # Account Management
gem 'oauth2', '0.4.1'             # oAuth providers management
gem 'money'                       # Currency management
gem 'google_currency'             # Currency Exchange conversion
gem 'mysql2', '0.3.11'            # MySQL DB
gem 'redis'                       # Redis NoSQL DB
gem 'dalli'                       # Memcached
gem 'delayed_job', '2.1.4'        # Background Jobs
gem 'will_paginate'               # Paginating results
gem 'geocoder'                    # Geocoding Google-based
gem 'declarative_authorization'   # Access Control List
gem 'workflow'                    # State control
gem 'validates_timeliness', '~> 3.0.2'
gem 'acts_as_list'				        # Support for sortable associations
gem 'rabl'                        # JSON Views

gem 'exception_notification'

# File Uploads
gem 'paperclip', "~> 2.4"         # Attachements
gem 'aws-s3'                      # Upload to Amazon S3
gem 'aws-sdk'

# ActiveAdmin
gem 'activeadmin'
gem 'sass-rails'
gem 'meta_search',    '>= 1.1.0.pre'
gem 'ransack'                     # Object-based search

# i18n stored in active record
gem 'i18n-active_record',
    :git => 'git://github.com/svenfuchs/i18n-active_record.git',
    :branch => 'rails-3.2',
    :require => 'i18n/active_record'

#rakismet
gem 'rakismet'

group :test do
  gem 'turn', :require => false  # Pretty printed test output
  gem 'shoulda'
  gem "shoulda-matchers"
  gem 'factory_girl',   '~> 2.6.4'
  gem 'faker'
  gem 'mocha'
end

group :development do
  gem 'hirb'              # Console on Steroids :) https://github.com/cldwalker/hirb
  gem 'mail_view'
  gem 'taps'
  gem 'powder'
  gem 'heroku_san', "~> 2.1.4"  # Manages multiple production environments
end

group :development, :test do
  # Debugger, for installation see: http://pastie.org/3293194
  gem 'linecache19', '0.5.13'
  gem 'ruby-debug-base19', '0.11.26'
  gem "ruby-debug19", :require => 'ruby-debug'
end

group :production, :staging do
  gem 'rack-ssl-enforcer'
end