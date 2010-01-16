require File.dirname(__FILE__) + '/test_helper'

class RendererTest < Test::Unit::TestCase
  def setup
    SeleniumOnRails::PartialsSupport.send(:include, SeleniumOnRails::PathsTestHelper)
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

  def test_route
    get :test_file, :testname => 'html.html' #initialize the controller
    assert_equal 'http://test.host/selenium/tests/suite%2Ftest_case.sel', 
        @controller.url_for(:controller => 'selenium', :action => 'test_file', :testname => 'suite/test_case.sel')
  end
  
  def test_html
    expected =<<END
<html><head><title>test layout</title></head><body>
<p>Testing plain HTML</p>
<table>
  <tr><th colspan="3">Test HTML</th></tr>
  <tr><td>open</td><td>/selenium/setup</td><td>&nbsp;</td></tr>
</table>
<p>and it works...</p>
</body></html>
END
    File.open(test_path_for('html.html'), 'w+') { |index_file| index_file << expected }
    get :test_file, :testname => 'html.html'
    assert_headers
    
    assert_text_equal expected, @response.body
  end
  
  def test_path_for(name)
    "#{File.expand_path(File.dirname(__FILE__) + "/../test_data")}/#{name}"
  end
    
  def test_rhtml
    get :test_file, :testname => 'rhtml.rhtml'
    assert_headers
    expected =<<END
<html><head><title>test layout</title></head><body>
<table>
  <tr><th colspan="3">Rhtml</th></tr>
  <tr><td>open</td><td>/fi</td><td>&nbsp;</td></tr>
  <tr><td>open</td><td>/fo</td><td>&nbsp;</td></tr>
  <tr><td>open</td><td>/fum</td><td>&nbsp;</td></tr>
  <tr><td>assertTitle</td><td>Partial from RHTML</td><td>&nbsp;</td></tr>
</table>
</body></html>
END
    assert_text_equal expected, @response.body
  end
  
  def test_selenese
    get :test_file, :testname => 'selenese.sel'
    
    assert_headers
    expected =<<END
<html><head><title>test layout</title></head><body>
<p>Selenese <strong>support</strong></p>
<table>
<tr><th colspan="3">Selenese</th></tr>
<tr><td>open</td><td>/selenium/setup</td><td>&nbsp;</td></tr>
<tr><td>goBack</td><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td>assertTitle</td><td>Partial from Selenese</td><td>&nbsp;</td></tr>
</table>
<p>works.</p>

</body></html>
END
    assert_text_equal expected, @response.body
  end
  
  def test_rselenese
    get :test_file, :testname => 'rselenese.rsel'
    assert_headers
    expected = <<END
<html><head><title>test layout</title></head><body>
<table>
  <tr><th colspan="3">Rselenese</th></tr>
  <tr><td>open</td><td>/selenium/setup</td><td>&nbsp;</td></tr>
  <tr><td>open</td><td>/selenium/setup?keep_session=true</td><td>&nbsp;</td></tr>
  <tr><td>open</td><td>/selenium/setup?fixtures=all</td><td>&nbsp;</td></tr>
  <tr><td>open</td><td>/selenium/setup?fixtures=foo%2Cbar</td><td>&nbsp;</td></tr>
  <tr><td>open</td><td>/selenium/setup?clear_tables=foo%2Cbar&amp;amp;fixtures=all</td><td>&nbsp;</td></tr>
  <tr><td>assertAbsoluteLocation</td><td>exact:http://test.host/selenium/setup</td><td>&nbsp;</td></tr>
  <tr><td>assertTitle</td><td>selenium</td><td>&nbsp;</td></tr>
  <tr><td>assertTitle</td><td>Partial from RSelenese</td><td>&nbsp;</td></tr>
</table>
</body></html>
END
    assert_text_equal expected, @response.body
  end
  
  def test_partial_support
    get :test_file, :testname => 'partials/all_partials.rsel'
    assert_headers
    expected = <<END
<html><head><title>test layout</title></head><body>
<table>
  <tr><th colspan="3">All partials</th></tr>
  <tr><td>assertTitle</td><td>Partial from All partials</td><td>&nbsp;</td></tr>
  <tr><td>type</td><td>partial</td><td>HTML partial</td></tr>
  <tr><td>type</td><td>world</td><td>RHTML partial</td></tr>
  <tr><td>type</td><td>partial</td><td>Selenese partial</td></tr>
  <tr><td>type</td><td>world</td><td>RSelenese partial</td></tr>
  <tr><td>type</td><td>nesting</td><td>Nesting partial</td></tr>
  <tr><td>type</td><td>dlrow</td><td>RSelenese partial</td></tr>
</table>
</body></html>
END
    assert_text_equal expected, @response.body
  end

  def test_own_layout
    get :test_file, :testname => 'own_layout.html'
    assert_headers
    expected =<<END
<html>
  <head>
    <title>Test case with own layout</title>
    <style type="text/css"> body { background-color: #ccc; } </style>
  </head>
  <body>
    <table>
      <tr><th colspan="3">Test own layout</th></tr>
      <tr><td>open</td><td>/selenium/setup</td><td>&nbsp;</td></tr>
    </table>
  </body>
</html>
END
    assert_text_equal expected, @response.body
  end
  
  def test_not_found
    get :test_file, :testname => 'missing'
    assert_response 404
    assert_equal 'Not found', @response.body
  end
  
  def assert_headers
    assert_response :success
    assert_equal 'no-cache', @response.headers['Cache-control']
    assert_equal 'no-cache', @response.headers['Pragma']
    assert_equal '-1', @response.headers['Expires']
  end
   
end
