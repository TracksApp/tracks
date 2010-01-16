require File.dirname(__FILE__) + '/test_helper'
require 'mocha'

class SeleniumControllerTest < Test::Unit::TestCase

  def setup
    @controller = SeleniumController.new
    @controller.extend(SeleniumOnRails::PathsTestHelper)
    ActionController::Routing::Routes.draw
    SeleniumController.any_instance.stubs(:layout_path).returns(false)
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @result_dir = File.join(File.dirname(__FILE__), "..", "test_result")
    
    @suite = <<EOS
<script>
</script>
<table>
  <tr><td bgcolor="#ccffcc"><a href="/selenium/tests/foo.sel">Foo</a></td></tr>
  <tr><td bgcolor="#ccffcc"><a href="/selenium/tests/bar.sel">Bar</a></td></tr>
</table>
EOS
  end

  def teardown
    FileUtils.rm_rf @result_dir
  end
  
  def test_record_with_result
    @controller.instance_variable_set(:@result_dir, @result_dir)
    
    post :record, :suite => @suite, "testTable.1" => "<table></table>", "testTable.2" => "<table></table>"
    
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
  
  def test_result_hash
    post :record, :suite => @suite, "testTable.1" => "<table></table>", "testTable.2" => "<table></table>",
                  :result => 'Failed', :numTestFailures => "906", :numTestPasses => "1079", :numCommandFailures => '1027', 
                  :numCommandErrors => '57', :numCommandPasses => '3', :totalTime => "A long time"
    
    assert_equal 'Failed', assigns['result']['result']
    assert_equal '906', assigns['result']['numTestFailures']
    assert_equal '1079', assigns['result']['numTestPasses']
    assert_equal '1027', assigns['result']['numCommandFailures']
    assert_equal '57', assigns['result']['numCommandErrors']
    assert_equal '3', assigns['result']['numCommandPasses']
    assert_equal  'A long time', assigns['result']['totalTime']
  end
end
