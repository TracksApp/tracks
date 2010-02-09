Webrat.configure do |config|
  config.mode = :selenium
  config.application_environment = :selenium
  config.selenium_browser_startup_timeout = 30
end

Cucumber::Rails::World.use_transactional_fixtures = false
