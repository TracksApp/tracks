source 'https://rubygems.org'

gem 'actionpack-xml_parser', '~> 2.0'
gem 'activemodel-serializers-xml', '~> 1.0.3'

gem 'rails', '~> 7.1'

gem 'font-awesome-sass', '~> 6.7.2'
gem 'jquery-rails', '~> 4.6'
gem 'jquery-ui-rails', '~>8.0.0'
gem 'aasm', '~> 5.5.1'
gem 'acts_as_list'
gem 'bcrypt', '~> 3.1.20'
gem 'htmlentities'
gem "kt-paperclip", "~> 7.2"
gem 'puma', '~> 6.6'
gem 'rails_autolink'
gem 'RedCloth'
gem 'sanitize', '~> 7.0'
gem 'tracks-chartjs-ror'
gem 'will_paginate'

gem 'rexml'

# Use --without <group> argument to skip unnecessary drivers
gem 'sqlite3', '~> 2.7', group: :sqlite
gem 'mysql2', '~> 0.5', group: :mysql
gem 'pg', '~> 1.5', group: :postgresql

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'mini_racer', group: :therubyracer

gem 'sprockets-rails'
gem 'coffee-rails', '~> 5.0.0'
gem 'dartsass-sprockets'
gem 'bootstrap-sass', '3.4.1'
gem 'terser'
gem 'listen'
gem 'tolk', '~> 6.0.0'

group :development, :optional => true do
  gem 'spring', '~> 4'
  gem 'yard'

  gem 'bullet'
  gem 'rack-mini-profiler'
  gem 'solargraph'

  gem 'i18n-tasks', '~> 1.0.15'
end

group :development, :test, :optional => true do
  gem 'byebug'
  gem 'rubocop', '~> 1.78'
end

group :test, :optional => true do
  # get test coverage info on codeclimate
  gem 'codeclimate-test-reporter', '1.0.9'
  gem 'database_cleaner', '~> 2'
  gem 'factory_bot_rails'
  gem 'minitest-stub-const'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'rails-dom-testing', '~> 2.3.0'
  gem 'rspec-expectations'
  gem 'simplecov'
end

group :stripe, :optional => true do
  gem 'stripe'
end
