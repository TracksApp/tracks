# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils    = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# We store more than 4K of data in the session during some tests.
# Override the hard-coded cookie session store to use a memory store for tests.
# See http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/5519ca7fd4dde3c1
class ActionController::RackRequest
  DEFAULT_SESSION_OPTIONS = {
    :database_manager => CGI::Session::MemoryStore, # store data in memory
    :prefix           => "ruby_sess.",    # prefix session file names
    :session_path     => "/",             # available to all paths in app
    :session_key      => "_session_id",
    :cookie_only      => false,
    :session_http_only=> true
  }
end

# Overwrite the default settings for fixtures in tests. See Fixtures 
# for more details about these settings.
# config.transactional_fixtures = true
# config.instantiated_fixtures = false
# config.pre_loaded_fixtures = false
SITE_CONFIG['salt'] ||= 'change-me'

config.time_zone = 'UTC'

config.after_initialize do
  require File.expand_path(File.dirname(__FILE__) + "/../../test/selenium_helper")
end

config.gem "flexmock"
config.gem "ZenTest", :lib => "zentest"
config.gem "hpricot"
config.gem "hoe"

# config.gem for rspec is in environment.rb. Needed for rake to work which loads
# the rspec.task file
config.gem "rspec-rails", :lib => false, :version => ">=1.2.2"
config.gem "webrat", :lib => false, :version => ">=0.4.3"
config.gem "cucumber", :lib => false, :version => ">=0.3.0"
config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
