source 'https://rubygems.org'

gem 'rails', '~>4.0.0'
gem 'sass-rails', '~>4.0.0'
gem 'coffee-rails', '~>4.0.0'

# todo: remove xml api 
gem 'actionpack-xml_parser', github: 'rails/actionpack-xml_parser'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer'

gem 'uglifier', '>=1.3.0'

gem 'jquery-rails'

# you may comment out the database driver you will not be using.
# This will prevent a native build of the driver. Building native drivers is not 
# always possible on all hosters
gem "sqlite3"
gem "mysql2"

gem "RedCloth"
gem "sanitize"
gem "will_paginate"
gem "acts_as_list"
gem "aasm"
gem "htmlentities"
gem "swf_fu"
gem "rails_autolink"
gem "cache_digests"
gem "rack-mini-profiler"

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

group :development do
  gem "yard"
  gem "tolk"
  gem "bullet"
end

group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "cucumber-rails", :require => false
  gem "rspec-expectations"
  gem "database_cleaner"
  gem "mocha", :require => false

  gem "aruba", :require => false
  gem "simplecov"
  gem "timecop"

  # Note that > 2.14 has problems, see: 
  # https://code.google.com/p/selenium/issues/detail?id=3075
  gem "selenium-webdriver" 
  
  # uncomment to use the webkit option. This depends on Qt being installed
  # gem "capybara-webkit"
  
  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"
end
