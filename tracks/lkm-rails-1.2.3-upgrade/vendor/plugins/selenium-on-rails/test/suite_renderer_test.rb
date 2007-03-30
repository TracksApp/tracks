require File.dirname(__FILE__) + '/test_helper'

class SuiteRendererTest < Test::Unit::TestCase
  def setup
    @controller = SeleniumController.new
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
    expected =<<END
<html><head><title>test layout</title></head><body>
<script type="text/javascript">
<!--
function openSuite(selector) {
  var suite = selector.options[selector.selectedIndex].value;
  if(suite == "header") return;
  if(top.location.href != location.href) //inside a frame
    top.location =  "/selenium/TestRunner.html?test=tests" + suite
  else
    window.location = "/selenium/tests" + suite
}
//-->
</script>
<select onchange="openSuite(this)">
  <option value="header">Suites:</option>
  <option value="">..</option>
</select>

<table>
  <tr><th>Empty suite</th></tr>
</table>
</body></html>
END
    assert_text_equal expected, @response.body
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
    expected =<<END
<html><head><title>test layout</title></head><body>
<script type="text/javascript">
<!--
function openSuite(selector) {
  var suite = selector.options[selector.selectedIndex].value;
  if(suite == "header") return;
  if(top.location.href != location.href) //inside a frame
    top.location =  "/selenium/TestRunner.html?test=tests" + suite
  else
    window.location = "/selenium/tests" + suite
}
//-->
</script>
<select onchange="openSuite(this)">
  <option value="header">Suites:</option>
  <option value="/empty_suite">Empty suite</option>
  <option value="/partials">Partials</option>
  <option value="/suite_one">Suite one</option>
  <option value="/suite_two">Suite two</option>
  <option value="/suite_one/subsuite">Suite one.Subsuite</option>
</select>

<table>
  <tr><th>All test cases</th></tr>
  <tr><td><a href="/selenium/tests/html.html">Html</a></td></tr>
  <tr><td><a href="/selenium/tests/own_layout.html">Own layout</a></td></tr>
  <tr><td><a href="/selenium/tests/rhtml.rhtml">Rhtml</a></td></tr>
  <tr><td><a href="/selenium/tests/rselenese.rsel">Rselenese</a></td></tr>
  <tr><td><a href="/selenium/tests/selenese.sel">Selenese</a></td></tr>
  <tr><td><a href="/selenium/tests/partials/all_partials.rsel">Partials.All partials</a></td></tr>
  <tr><td><a href="/selenium/tests/suite_one/suite_one_testcase1.sel">Suite one.Suite one testcase1</a></td></tr>
  <tr><td><a href="/selenium/tests/suite_one/suite_one_testcase2.sel">Suite one.Suite one testcase2</a></td></tr>
  <tr><td><a href="/selenium/tests/suite_one/subsuite/suite_one_subsuite_testcase.sel">Suite one.Subsuite.Suite one subsuite testcase</a></td></tr>
  <tr><td><a href="/selenium/tests/suite_two/suite_two_testcase.sel">Suite two.Suite two testcase</a></td></tr>
</table>
</body></html>
END
    assert_text_equal expected, @response.body
  end

  def test_suite_one
    get :test_file, :testname => 'suite_one'
    assert_response :success
    expected =<<END
<html><head><title>test layout</title></head><body>
<script type="text/javascript">
<!--
function openSuite(selector) {
  var suite = selector.options[selector.selectedIndex].value;
  if(suite == "header") return;
  if(top.location.href != location.href) //inside a frame
    top.location =  "/selenium/TestRunner.html?test=tests" + suite
  else
    window.location = "/selenium/tests" + suite
}
//-->
</script>
<select onchange="openSuite(this)">
  <option value="header">Suites:</option>
  <option value="">..</option>
  <option value="/suite_one/subsuite">Subsuite</option>
</select>

<table>
  <tr><th>Suite one</th></tr>
  <tr><td><a href="/selenium/tests/suite_one/suite_one_testcase1.sel">Suite one testcase1</a></td></tr>
  <tr><td><a href="/selenium/tests/suite_one/suite_one_testcase2.sel">Suite one testcase2</a></td></tr>
  <tr><td><a href="/selenium/tests/suite_one/subsuite/suite_one_subsuite_testcase.sel">Subsuite.Suite one subsuite testcase</a></td></tr>
</table>
</body></html>
END
    assert_text_equal expected, @response.body
  end
  
  def test_sub_suite
    get :test_file, :testname => 'suite_one/subsuite'
    assert_response :success
    expected =<<END
<html><head><title>test layout</title></head><body>
<script type="text/javascript">
<!--
function openSuite(selector) {
  var suite = selector.options[selector.selectedIndex].value;
  if(suite == "header") return;
  if(top.location.href != location.href) //inside a frame
    top.location =  "/selenium/TestRunner.html?test=tests" + suite
  else
    window.location = "/selenium/tests" + suite
}
//-->
</script>
<select onchange="openSuite(this)">
  <option value="header">Suites:</option>
  <option value="/suite_one">..</option>
</select>

<table>
  <tr><th>Subsuite</th></tr>
  <tr><td><a href="/selenium/tests/suite_one/subsuite/suite_one_subsuite_testcase.sel">Suite one subsuite testcase</a></td></tr>
</table>
</body></html>
END
    assert_text_equal expected, @response.body
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
