source 'https://rubygems.org'

gem 'rails', '~>3.2'

# you may comment out the database driver you will not be using.
# This will prevent a native build of the driver. Building native drivers is not 
# always possible on all hosters
gem "sqlite3", "~>1.3"
gem "mysql2", "~>0.3"

gem "RedCloth", "~>4.2.9"
gem "formatize", "~>1.1"
gem "sanitize", "~>2.0"
gem "will_paginate", "~>3.0"
gem "acts_as_list", "~>0.1"
gem "aasm", "~>3.0"
gem "htmlentities", "~>4.3"
gem "swf_fu", "~>2.0"
gem "rails_autolink", "~>1.0"
gem "cache_digests", :path => 'vendor/gems/cache_digests-0.1.0' # vendored for Ruby 1.8.7 compatibility
gem "rack-mini-profiler", "~>0.1"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~>3.2"
  gem 'coffee-rails', "~>3.2"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', "~>0.11"

  gem 'uglifier', "~>1.3"
end

gem 'jquery-rails', "~>2.1"

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', "~>3.0"

group :development do
  if RUBY_VERSION.to_f >= 1.9
    # gem "ruby-debug19", :require => 'ruby-debug'
  else
    gem "ruby-debug"
  end
  gem "yard", "~>0.8"
  gem "tolk", "~>1.3"
  gem "bullet", "~>4.3"
end

group :test do
  gem "factory_girl_rails", "~>4.1"
  gem "capybara", "~>2.0"
  gem "cucumber-rails", "~>1.3", :require => false
  gem "database_cleaner", "~>0.9"
  gem "aruba", "~>0.5"
  gem "simplecov", "~>0.7"
  gem "timecop", "~>0.5"

  # Note that > 2.14 has problems, see: 
  # https://code.google.com/p/selenium/issues/detail?id=3075
  gem "selenium-webdriver", "~>2.27" 
  
  # uncomment to use the webkit option. This depends on Qt to be installed
  # gem "capybara-webkit"
  
  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"
end
