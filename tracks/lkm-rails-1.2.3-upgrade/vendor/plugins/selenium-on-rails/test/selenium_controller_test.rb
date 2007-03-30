require File.dirname(__FILE__) + '/test_helper'
require "selenium_controller"

class SeleniumControllerTest < Test::Unit::TestCase

  def setup
    @controller = SeleniumController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @result_dir = File.join(File.dirname(__FILE__), "..", "test_result")
  end

  def teardown
    FileUtils.rm_rf @result_dir
  end
  
  def test_record_with_result
    SeleniumOnRailsConfig.configs["result_dir"] = @result_dir
    suite = <<EOS
<script>
</script>
<table>
  <tr><td bgcolor="#ccffcc"><a href="/selenium/tests/foo.sel">Foo</a></td></tr>
  <tr><td bgcolor="#ccffcc"><a href="/selenium/tests/bar.sel">Bar</a></td></tr>
</table>
EOS
    post :record, :suite => suite,
      "testTable.1" => "<table></table>",
      "testTable.2" => "<table></table>"
    cur_result_dir = File.join(@result_dir, "default")
    assert File.directory?(cur_result_dir)
    assert_equal ["blank.html", "index.html", "suite.html", "test1.html", "test2.html"], 
      Dir.glob("#{cur_result_dir}/*.html").map{|path| File.basename(path)}.sort
    expected = <<EOS
<html>
<head>
<link rel="stylesheet" type="text/css" href="selenium-test.css">
</head>
<body>
<table>
  <tr><td bgcolor="#ccffcc"><a href="test1.html" target="testcase">Foo</a></td></tr>
  <tr><td bgcolor="#ccffcc"><a href="test2.html" target="testcase">Bar</a></td></tr>
</table>
</body></html>
EOS
    assert_equal expected, File.read("#{cur_result_dir}/suite.html")
  end
end
