require File.dirname(__FILE__) + '/test_helper'

class SuiteRendererTest < Test::Unit::TestCase
  def setup
    @controller = SeleniumController.new
    @controller.extend(SeleniumOnRails::PathsTestHelper)
    ActionController::Routing::Routes.draw
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.layout_override =<<END
<html><head><title>test layout</title></head><body>
@content_for_layout
</body></html>
END
  end
  
  def test_empty_suite
    get :test_file, :testname => 'empty_suite'
    
    assert_response :success
    assert_tag :tag => "title", :content => "test layout"
    assert_tag :tag => "script", :attributes => {:type => "text/javascript"}
    assert_tag :tag => "select", :attributes => {:onchange => "openSuite(this)"}, 
               :descendant => {:tag => "option", :attributes => {:value => "header"}, :content => "Suites:"},
               :descendant => {:tag => "option", :attributes => {:value => ""}, :content => ".."}
               
    assert_tag :tag => "table",
              :descendant => {:tag => "th", :content => "Empty suite"}
  end

  def test_root_suite
    _test_root_suite ''
  end
  
  def test_test_suite_html
    #TestSuite.html is the default name the Selenium Runner tries to run
    _test_root_suite 'TestSuite.html'
  end
  
  def _test_root_suite testname
    get :test_file, :testname => testname
    assert_response :success
    
    assert_tag :tag => "title", :content => "test layout"
    assert_tag :tag => "script", :attributes => {:type => "text/javascript"}
    assert_tag :tag => "select", :attributes => {:onchange => "openSuite(this)"}, 
               :descendant => {:tag => "option", :attributes => {:value => "header"}, :content => "Suites:"},
               :descendant => {:tag => "option", :attributes => {:value => "/partials"}, :content => "Partials"},
               :descendant => {:tag => "option", :attributes => {:value => "/suite_one"}, :content => "Suite one"},
               :descendant => {:tag => "option", :attributes => {:value => "/suite_two"}, :content => "Suite two"},
               :descendant => {:tag => "option", :attributes => {:value => "/suite_one/subsuite"}, :content => "Suite one.Subsuite"}
               
    assert_tag :tag => "table",
              :descendant => {:tag => "th", :content => "All test cases"},
              :descendant => {:tag => "td", :content => "Html"},
              :descendant => {:tag => "td", :content => "Own layout"},
              :descendant => {:tag => "td", :content => "Rhtml"},
              :descendant => {:tag => "td", :content => "Rselenese"},
              :descendant => {:tag => "td", :content => "Selenese"},
              :descendant => {:tag => "td", :content => "Partials.All partials"},
              :descendant => {:tag => "td", :content => "Suite one.Suite one testcase1"},
              :descendant => {:tag => "td", :content => "Suite one.Suite one testcase2"},
              :descendant => {:tag => "td", :content => "Suite one.Subsuite.Suite one subsuite testcase"},
              :descendant => {:tag => "td", :content => "Suite two.Suite two testcase"}
  end

  def test_suite_one
    get :test_file, :testname => 'suite_one'
    
    assert_response :success   
    assert_tag :tag => "title", :content => "test layout"
    assert_tag :tag => "script", :attributes => {:type => "text/javascript"}
    assert_tag :tag => "select", :attributes => {:onchange => "openSuite(this)"}, 
               :descendant => {:tag => "option", :attributes => {:value => "header"}, :content => "Suites:"},
               :descendant => {:tag => "option", :attributes => {:value => ""}, :content => ".."},
               :descendant => {:tag => "option", :attributes => {:value => "/suite_one/subsuite"}, :content => "Subsuite"}
               
    assert_tag :tag => "table",
              :descendant => {:tag => "th", :content => "Suite one"},
              :descendant => {:tag => "td", :content => "Suite one testcase1"},
              :descendant => {:tag => "td", :content => "Suite one testcase2"},
              :descendant => {:tag => "td", :content => "Subsuite.Suite one subsuite testcase"}
  end
  
  def test_sub_suite
    get :test_file, :testname => 'suite_one/subsuite'
    
    assert_response :success
    assert_tag :tag => "title", :content => "test layout"
    assert_tag :tag => "script", :attributes => {:type => "text/javascript"}
    assert_tag :tag => "select", :attributes => {:onchange => "openSuite(this)"}, 
               :descendant => {:tag => "option", :attributes => {:value => "header"}, :content => "Suites:"},
               :descendant => {:tag => "option", :attributes => {:value => "/suite_one"}, :content => ".."}
               
    assert_tag :tag => "table",
              :descendant => {:tag => "th", :content => "Subsuite"},
              :descendant => {:tag => "td", :content => "Suite one subsuite testcase"}
  end
  
  def test_missing_tests_directory
    def @controller.selenium_tests_path
      File.join(File.dirname(__FILE__), 'invalid')
    end
    get :test_file, :testname => ''
    assert_response 404
    assert_equal "Did not find the Selenium tests path (#{File.join(File.dirname(__FILE__), 'invalid')}). Run script/generate selenium",  @response.body
  end
  
end
