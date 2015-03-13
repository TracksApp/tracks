source 'https://rubygems.org'

gem 'rails', '~>4.1.8'
gem 'sass-rails', '~>4.0'
gem 'coffee-rails', '~>4.0'

#gem 'json'

# todo: remove xml api
gem 'actionpack-xml_parser', '>=1.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', group: :therubyracer

gem 'uglifier', '>=1.3.0'

gem 'jquery-rails'

# you may comment out the database driver(s) you will not be using.
# This will prevent a native build of the driver. Building native drivers is not
# always possible on all platforms
# Alternatively use --without <group> arguments to bundler to not install that group
gem "sqlite3", group: :sqlite
gem "mysql2", group: :mysql

gem "RedCloth"
gem "sanitize"
gem "will_paginate"
gem "acts_as_list"
gem "aasm"
gem "htmlentities"
gem "swf_fu"
gem "rails_autolink"

# To use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

group :development do
  gem "spring"
  gem "spring-commands-cucumber"
  gem "yard"

  gem 'tolk', '~> 1.6.0'

  gem "bullet"
  gem "rack-mini-profiler"
  gem "rack-dev-mark"
  gem "activerecord-deprecated_finders"
end

group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "cucumber-rails", :require => false
  gem "rspec-expectations"
  gem "database_cleaner"
  gem "mocha", :require => false

  gem "aruba", ">=0.5.4", :require => false

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
