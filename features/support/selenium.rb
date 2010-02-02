Webrat.configure do |config|
  config.mode = :selenium
  config.application_environment = :selenium
end

Cucumber::Rails::World.use_transactional_fixtures = false
