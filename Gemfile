source 'https://rubygems.org'

gem 'rails', '~>4.1.0'
gem 'sass-rails', '~>4.0'
gem 'coffee-rails', '~>4.0'

#gem 'json'

# todo: remove xml api
gem 'actionpack-xml_parser', git: 'https://github.com/rails/actionpack-xml_parser'

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

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

group :development do
  gem "yard"
  gem 'tolk', '>=1.5.0'
  gem "bullet"
  gem "rack-mini-profiler"
end

group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "cucumber-rails", :require => false
  gem "rspec-expectations"
  gem "database_cleaner"
  gem "mocha", :require => false

  gem "aruba", git: 'https://github.com/cucumber/aruba', :require => false  # need 0.5.4 for piping files; 0.5.3 is latest
  gem "timecop", "~> 0.6.2"

  # Note that > 2.14 has problems, see:
  # https://code.google.com/p/selenium/issues/detail?id=3075
  gem "selenium-webdriver"

  # uncomment to use the webkit option. This depends on Qt being installed
  # gem "capybara-webkit"

  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"

  gem "simplecov"
  # get test coverage info on codeclimate
  gem "codeclimate-test-reporter", group: :test, require: nil
end
