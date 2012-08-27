source 'https://rubygems.org'

gem 'rails'

# you may comment out the database driver you will not be using.
# This will prevent a native build of the driver. Building native drivers is not always possible on all hosters
gem "sqlite3"
gem "mysql2"

gem "RedCloth"
gem "formatize"
gem "sanitize"
gem "will_paginate"
gem "acts_as_list"
gem "aasm"
gem "htmlentities"
gem "swf_fu"
gem "rails_autolink"
gem "cache_digests" #, :git => 'git://github.com/rails/cache_digests.git'
gem "rack-mini-profiler"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby

  gem 'uglifier'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby'

group :development do
  if RUBY_VERSION.to_f >= 1.9
    # gem "ruby-debug19", :require => 'ruby-debug'
    gem "mongrel", ">=1.2.0.pre2"
  else
    gem "ruby-debug"
    gem "mongrel"
  end
  gem "yard"
  gem "tolk"
  gem "bullet"
end

group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "selenium-webdriver" # Note that > 2.14 has problems: https://code.google.com/p/selenium/issues/detail?id=3075
  gem "database_cleaner"
  gem "cucumber-rails"
  gem "aruba"
  
  # uncomment to use the webkit option. This depends on Qt to be installed
  #gem "capybara-webkit"
  
  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"
end
