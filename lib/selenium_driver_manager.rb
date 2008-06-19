require 'singleton'
require 'selenium'

class SeleniumDriverManager
  include Singleton
  
  def running_selenium_driver
    start
    driver
  end
  
  def start
    return if running?
    driver.start
    @running = true
  end
  
  def stop
    return unless running?
    driver.stop
    @running = false
  end
  
  def running?
    @running
  end
  
  protected
  
  def driver
    @driver ||= Selenium::SeleniumDriver.new("localhost", 4444, "*chrome", "http://localhost", 15000)
  end
  
end
