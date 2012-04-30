require 'aruba/cucumber'

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
# BUG in this version of cucumber/capybara: require 'cucumber/rails/capybara_javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript

Capybara.default_wait_time = 5
Capybara.javascript_driver = ENV["JS_DRIVER"] ? ENV["JS_DRIVER"].to_sym : :selenium

if Capybara.javascript_driver == :webkit
  require 'capybara/webkit'
end
