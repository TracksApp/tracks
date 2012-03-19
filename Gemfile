source :gemcutter
source "http://gems.github.com/"

gem "rake", "~>0.8.7"
gem "rails", "~>2.3.12"
gem "highline", "~>1.5.0"
gem "RedCloth", "4.2.8"
gem "sanitize", "~>1.2.1"
gem "rack", "1.1.0"
gem "will_paginate", "~> 2.3.15"
gem "has_many_polymorphs", "~> 2.13"
gem "acts_as_list", "~>0.1.4"
gem "aasm", "~>2.2.0"
gem "rubyjedi-actionwebservice", :require => "actionwebservice"
gem "rubycas-client", "~>2.2.1"
gem "ruby-openid", :require => "openid"

# you may comment out the database driver you will not be using.
# This will prevent a native build of the driver. Building native drivers is not always possible on all hosters
gem "sqlite3"
gem "mysql"

gem 'bcrypt-ruby', '~> 2.1.4'
gem 'htmlentities', '~> 4.3.0'
gem "mail"

if RUBY_VERSION.to_f >= 1.9
	gem "soap4r-ruby1.9"
else
	gem "soap4r", "~>1.5.8"
end

group :development do
  if RUBY_VERSION.to_f >= 1.9
    gem "ruby-debug19"
    gem "mongrel", "1.2.0.pre2"
  else
    gem "ruby-debug"
    gem "mongrel"
  end
  gem "yard"
end

group :test do
  gem "test-unit", "1.2.3"
  gem "flexmock"
  gem "ZenTest", ">=4.0.0"
  gem "hpricot"
  gem "hoe"
  gem "rspec-rails", "~>1.3.3"
  gem "thoughtbot-factory_girl"
  gem 'memory_test_fix', '~>0.1.3'
  gem "capybara", ">=0.3.5"
  gem "selenium-webdriver" # Note that > 2.14 has problems: https://code.google.com/p/selenium/issues/detail?id=3075
  gem "database_cleaner", ">=0.5.0"
  gem "cucumber-rails", "~>0.3.2"
  gem "aruba", "0.2.2", :path => "vendor/gems/aruba-0.2.2"
  
  # uncomment to use the webkit option. This depends on Qt to be installed
  #gem "capybara-webkit"
  
  # uncomment to be able to make screenshots from scenarios
  #gem "capybara-screenshot"
  #gem "launchy"
end
