# commented out because aruba 0.5 conflics
# require 'aruba/cucumber'

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
# BUG in this version of cucumber/capybara: require 'cucumber/rails/capybara_javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript

Capybara.default_wait_time = 5
Capybara.javascript_driver = ENV["JS_DRIVER"] ? ENV["JS_DRIVER"].to_sym : :selenium
Capybara.ignore_hidden_elements = false # make find(css) find hidden elements

if Capybara.javascript_driver == :webkit
#  require 'capybara/webkit'
end

if Capybara.javascript_driver == :selenium
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['intl.accept_languages'] = 'en'
  Capybara.register_driver :selenium_english do |app|
    Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
  end
  Capybara.javascript_driver = :selenium_english
end
