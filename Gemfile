source 'https://rubygems.org'

gem 'rails', '~> 4.1.11'
gem 'sass-rails', '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.1'

#gem 'json'

# todo: remove xml api
gem 'actionpack-xml_parser', '~> 1.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer'

gem 'uglifier', '~> 2.5.3'

gem 'jquery-rails', '~> 3.1.2'

# you may comment out the database driver you will not be using.
# This will prevent a native build of the driver. Building native drivers is not
# always possible on all hosters
gem "sqlite3", "~> 1.3.9"
gem "mysql2", "~> 0.3.16"

gem "RedCloth", "~> 4.2.9"
gem "sanitize", "~> 3.0.2"
gem "will_paginate", "~> 3.0.7"
gem "acts_as_list", "~> 0.4.0"
gem "aasm", "~> 3.4.0"
gem "htmlentities", "~> 4.3.2"
gem "swf_fu", "~> 2.0.4"
gem "rails_autolink", "~> 1.1.6"
gem "cache_digests", "~> 0.3.1"

# To use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

group :development do
  gem "spring", "~> 1.1.3"
  gem "spring-commands-cucumber", "~> 1.0.1"
  gem "yard", "~> 0.8.7.4"

  gem 'tolk', '~> 1.6.0'

  gem "bullet", "~> 4.13.2"
  gem "rack-mini-profiler", "~> 0.9.2"
  gem "rack-dev-mark", "0.7.3"
  gem "activerecord-deprecated_finders", "~> 1.0.3"
end

group :test do
  gem "factory_girl_rails", "~> 4.4.1"
  gem "capybara", "~> 2.4.3"
  gem "cucumber-rails", "~> 1.4.1", :require => false
  gem "rspec-expectations", "~> 3.1.2"
  gem "database_cleaner", "~> 1.3.0"
  gem "mocha", "~> 1.1.0", :require => false

  gem "aruba", "~> 0.6.1", :require => false

  # Note that > 2.14 has problems, see:
  # https://code.google.com/p/selenium/issues/detail?id=3075
  gem "selenium-webdriver"

  # uncomment to use the webkit option. This depends on Qt being installed
  # gem "capybara-webkit"

  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"

  gem "simplecov", "~> 0.9.1"
  # get test coverage info on codeclimate
  gem "codeclimate-test-reporter", "~> 0.4.1", group: :test, require: nil
end
