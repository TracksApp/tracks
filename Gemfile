source 'https://rubygems.org'

gem 'rails', '~> 4.2.6'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.1.0'

#gem 'json'

# todo: remove xml api
gem 'actionpack-xml_parser', '>=1.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', group: :therubyracer

gem 'uglifier', '>=1.3.0'

gem 'jquery-rails' , '~> 3.1.3'
gem 'jquery-ui-rails' , '~>5.0.5'

# you may comment out the database driver(s) you will not be using.
# This will prevent a native build of the driver. Building native drivers is not
# always possible on all platforms
# Alternatively use --without <group> arguments to bundler to not install that group
gem "sqlite3", group: :sqlite
gem "mysql2", "~> 0.3.17", group: :mysql

gem "RedCloth"
gem "sanitize", ">=3.0.0"
gem "will_paginate"
gem "acts_as_list"
gem "aasm", '~> 3.4.0'
gem "htmlentities"
gem "swf_fu"
gem "rails_autolink"
gem 'thin'
gem 'paperclip'

# To use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

gem "bootstrap-sass", "3.3.3"
gem "font-awesome-sass", "~> 4.5.0"

group :development do
  gem "spring"
  gem "yard"

  gem 'tolk', '~> 1.9.3'

  gem "bullet"
  gem "rack-mini-profiler"
  gem "rack-dev-mark"
end

group :development, :test do
  gem 'pry'
  gem "rubocop", "~> 0.49", require: false
end

group :test do
  # Pull in the fix for rails-dom-testing issue #42
  # TODO: Remove with Rails 5 and rails-dom-testing 2.x
    gem 'rails-dom-testing', git: 'https://github.com/rails/rails-dom-testing', ref: 'a64f30514ee65f172c43f42cfd4500b5e11a561a'


  gem "factory_bot_rails"
  gem "rspec-expectations"
  gem "database_cleaner"
  gem "mocha", :require => false
  gem "minitest-stub-const"

  gem "selenium-webdriver", "~> 2.53"

  # uncomment to use the webkit option. This depends on Qt being installed
  # gem "capybara-webkit"

  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"

  gem "simplecov"
  # get test coverage info on codeclimate
  gem "codeclimate-test-reporter", "1.0.7", group: :test, require: nil
end
