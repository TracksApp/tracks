task :test_acceptance => 'test:acceptance'
namespace :test do
  desc 'Run Selenium tests in all browsers'
  task :acceptance do
    require File.dirname(__FILE__) + '/../lib/selenium_on_rails/acceptance_test_runner'
    SeleniumOnRails::AcceptanceTestRunner.new.run
  end
end
