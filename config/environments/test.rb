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

# Unique cookies and use cookies for session
config.action_controller.session_store = :cookie_store
config.action_controller.session = { :key => 'TracksTest', :secret => SITE_CONFIG['salt'] * (30.0 /  SITE_CONFIG['salt'].length).ceil }

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

