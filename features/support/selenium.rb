if ENV["RAILS_ENV"] == "selenium"
  puts "Configuring to use Selenium with Webrat for Cucumber stories"
  Webrat.configure do |config|
    config.mode = :selenium

    config.application_environment = :selenium
    # use only if you run a separate rails test server instance and do not
    # want webrat to start one for you
    # config.application_port = 3001

    config.selenium_browser_startup_timeout = 30
    # use only if you run a separate selenium server instance and do not
    # want webrat to start one for you
    # config.selenium_server_address = "localhost"
    # config.selenium_server_port = "4444"
  end

  Cucumber::Rails::World.use_transactional_fixtures = false
end
