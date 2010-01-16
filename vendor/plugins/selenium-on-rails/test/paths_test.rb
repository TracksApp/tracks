require File.dirname(__FILE__) + '/test_helper'
require 'mocha'
RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "/")

class SeleniumOnRails::PathsTest < Test::Unit::TestCase
  
  include SeleniumOnRails::Paths
  
  def test_selenium_tests_path_when_config_has_not_selenium_tests_path
    SeleniumOnRailsConfig.expects(:get).with("selenium_tests_path").returns(nil)
    assert_equal "#{RAILS_ROOT}/test/selenium", selenium_tests_path
  end
  
  def test_selenium_tests_path_when_config_has_selenium_tests_path
    SeleniumOnRailsConfig.expects(:get).with("selenium_tests_path").returns("path").at_least_once
    assert_equal "path", selenium_tests_path
  end
  
  def test_fixtures_path_when_config_has_not_fixtures_path
    SeleniumOnRailsConfig.expects(:get).with("fixtures_path").returns(nil)
    assert_equal "#{RAILS_ROOT}/test/fixtures", fixtures_path
  end
  
  def test_fixtures_path_when_config_has_fixtures_path
    SeleniumOnRailsConfig.expects(:get).with("fixtures_path").returns("path").at_least_once
    assert_equal "path", fixtures_path
  end
  
  def test_view_path
    assert_equal File.expand_path("#{RAILS_ROOT}/../lib/views/my_view"), view_path('my_view')
  end
  
  def test_layout_path
    assert_equal "layout.rhtml", layout_path
  end
  
  def test_skip_file_when_file_contain_CVS
    assert skip_file?("file/with/CVS/in/the/middle/of/path")
  end

  def test_skip_file_when_file_contain_dot
    assert skip_file?("file/with/./(dot)/in/the/middle/of/path")
  end

  def test_skip_file_when_file_contain_underline
    assert skip_file?("file/with/_underline/in/the/middle/of/path")
  end
  
  def test_skip_file_when_file_contain_accent_mark
    assert skip_file?("file/with/mark~/in/the/middle/of/path")
  end

  def test_skip_file_when_file_does_not_have_any_reason_to_skip
    assert !skip_file?("my/valid/file")
  end
  
  def test_selenium_path
    assert_equal File.expand_path("#{RAILS_ROOT}/../selenium-core") + "/", selenium_path
  end

  def test_selenium_path_when_selenium_core_installation_is_not_found
    selenium_core_path = File.expand_path(File.dirname(__FILE__) + "/../selenium-core")
    
    File.expects(:exist?).with("#{selenium_core_path}/core/TestRunner.html").returns(false)
    File.expects(:exist?).with("#{selenium_core_path}/selenium/TestRunner.html").returns(false)
    File.expects(:exist?).with("#{selenium_core_path}/javascript/TestRunner.html").returns(false)
    File.expects(:exist?).with("#{selenium_core_path}/TestRunner.html").returns(false)
    @@selenium_path = nil
    assert_raise(RuntimeError) { selenium_path }
  end
  
end