Webrat.configure do |config|
  config.mode = :selenium
  config.application_environment = :selenium
  config.selenium_browser_startup_timeout = 30
  #config.selenium_server_address = "localhost"
end

Cucumber::Rails::World.use_transactional_fixtures = false

require 'database_cleaner'

# clean the database once when starting
DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
