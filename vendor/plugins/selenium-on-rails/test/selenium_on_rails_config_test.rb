require File.dirname(__FILE__) + '/test_helper'
require 'mocha'

class SeleniumOnRailsConfig
  def self.reset_config
    @@configs = nil
  end
end

class SeleniumOnRailsConfigTest < Test::Unit::TestCase
  
  def setup
    SeleniumOnRailsConfig.reset_config
    @selenium_file = File.join(RAILS_ROOT, 'config', 'selenium.yml')
    @config_file = File.expand_path(File.dirname(__FILE__) + '/../config.yml')
    @selenium_content = File.read(File.dirname(__FILE__) + '/fixtures/selenium.yml')
    @config_content = File.read(File.dirname(__FILE__) + '/fixtures/config.yml')
  end

  def test_get_selenium_yaml
    File.expects(:exist?).with(@selenium_file).returns(true)
    IO.expects(:read).with(@selenium_file).returns(@selenium_content)
    IO.expects(:read).with(@config_file).never
    IO.expects(:exist?).with(@config_file).never
    
    assert_equal ["test_cache"], SeleniumOnRailsConfig.get(:environments)
    assert_equal({"firefox"=>"script/openfirefox"}, SeleniumOnRailsConfig.get(:browsers))
  end

  def test_get_when_config_yml_exists_but_selenium_yaml_not
    File.expects(:exist?).with(@selenium_file).returns(false)
    File.expects(:exist?).with(@config_file).returns(true)
    IO.expects(:read).with(@config_file).returns(@config_content)
    IO.expects(:read).with(@selenium_file).never
    
    assert_equal ["test"], SeleniumOnRailsConfig.get(:environments)
    expected_config = {"safari"=>"/Applications/Safari.app/Contents/MacOS/Safari",
                       "firefox"=>"/Applications/Firefox.app/Contents/MacOS/firefox-bin"} 
    
    assert_equal(expected_config, SeleniumOnRailsConfig.get(:browsers))
  end

end