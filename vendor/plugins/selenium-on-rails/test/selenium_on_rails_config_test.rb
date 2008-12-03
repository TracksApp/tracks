require File.dirname(__FILE__) + '/test_helper'
require 'mocha'

class SeleniumOnRailsConfigTest < Test::Unit::TestCase
  
  def test_config_file_in_config_directory
    File.stubs(:expand_path).returns("temporary")
    File.expects(:exist?).with("temporary").returns(false)
    File.expects(:exist?).with(File.join(RAILS_ROOT, 'config', 'selenium.yml')).returns(true)
    YAML.expects(:load_file).with(File.join(RAILS_ROOT, 'config', 'selenium.yml')).returns({:fake => "hash"})
    
    assert_equal({:fake => "hash"}, SeleniumOnRailsConfig.new.configs)
  end
  
  def test_setting_config_manually
    config = SeleniumOnRailsConfig.new
    config.configs["test"] = "result"
    
    assert_equal("result", config.configs["test"])
  end
end