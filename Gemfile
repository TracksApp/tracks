source :gemcutter
source :rubyforge
source "http://gems.github.com/"

gem "rake", "~>0.8.7"
gem "rails", "~>2.3.12"
gem "highline", "~>1.5.0"
gem "RedCloth", "4.2.3"
gem "soap4r"
gem "sanitize", "~>1.2.1"
gem "rack", "1.1.0"
gem "will_paginate", "~> 2.3.15"
gem "has_many_polymorphs", "~> 2.13"
gem "aasm", "2.2.0"
gem "actionwebservice", :git => "git://github.com/dejan/actionwebservice.git"
gem "rubycas-client"
gem "ruby-openid", :require => "openid"
gem "sqlite3"
gem 'bcrypt-ruby', '~> 2.1.4'

gem "webrat", ">=0.7.0", :groups => [:cucumber, :test]
gem "database_cleaner", ">=0.5.0", :groups => [:cucumber, :selenium]
gem "cucumber-rails", "~>0.3.0", :groups => :cucumber

group :test do
  gem "flexmock"
  gem "ZenTest", ">=4.0.0"
  gem "hpricot"
  gem "hoe"
  gem "rspec-rails", "~>1.3.3"
  gem "thoughtbot-factory_girl"
end

group :selenium do
  gem "selenium-client"
  gem "mongrel"
end

