source 'https://rubygems.org'

gem 'rails', '~> 6.0.3'
gem 'sassc-rails', '~> 2.1.2'
gem 'coffee-rails', '~> 5.0.0'

#gem 'json'

# todo: remove xml api
gem "actionpack-xml_parser", "~> 2.0"
gem "activemodel-serializers-xml", "~> 1.0.1"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', group: :therubyracer

gem 'uglifier', '>=1.3.0'

gem 'jquery-rails' , '~> 4.4'
gem 'jquery-ui-rails' , '~>6.0.1'

# you may comment out the database driver(s) you will not be using.
# This will prevent a native build of the driver. Building native drivers is not
# always possible on all platforms
# Alternatively use --without <group> arguments to bundler to not install that group
gem "sqlite3", group: :sqlite
gem "mysql2", "~> 0.5.3", group: :mysql

gem "RedCloth"
gem "sanitize", "~> 5.2"
gem "will_paginate"
gem "acts_as_list"
gem "aasm", '~> 5.1.1'
gem "htmlentities"
gem "rails_autolink"
gem 'puma', '~> 4.3'
gem 'paperclip'

# To use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.16'

gem 'chartjs-ror', :git => 'git://github.com/ZeiP/chartjs-ror.git'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

gem "bootstrap-sass", "3.4.1"
gem "font-awesome-sass", "~> 5.13.0"

group :development do
  gem "spring"
  gem "yard"

  gem 'tolk', '~> 4.0.0'

  gem "bullet"
  gem "rack-mini-profiler"
  gem "solargraph"
end

group :development, :test do
  gem 'byebug'
  gem 'listen'
  gem "rubocop", "~> 0.90", require: false
end

group :test do
  gem 'rails-controller-testing'
  gem 'rails-dom-testing', '~> 2.0.0'


  gem "factory_bot_rails"
  gem "rspec-expectations"
  gem "database_cleaner"
  gem "mocha", :require => false
  gem "minitest-stub-const"

  gem "selenium-webdriver", "~> 3.142"

  # uncomment to use the webkit option. This depends on Qt being installed
  # gem "capybara-webkit"

  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"

  gem "simplecov"
  # get test coverage info on codeclimate
  gem "codeclimate-test-reporter", "1.0.7", group: :test, require: nil
end
