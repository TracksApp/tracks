require File.dirname(__FILE__) + '/../test_helper'
require 'contexts_controller'

# Re-raise errors caught by the controller.
class ContextsController; def rescue_action(e) raise e end; end

class ContextXmlApiTest < ActionController::IntegrationTest
  fixtures :users, :contexts, :preferences

  @@context_name = "@newcontext"
  @@valid_postdata = "<request><context><name>#{@@context_name}</name></context></request>"
  
  def setup
    assert_test_environment_ok
  end

 def test_fails_with_invalid_xml_format
   # Fails too hard for test to catch 
   # authenticated_post_xml_to_context_create "<foo></bar>"
   # assert_equal 500, @integration_session.status
 end
    
  def test_fails_with_invalid_xml_format2
    authenticated_post_xml_to_context_create "<request><context></context></request>"
    assert_404_invalid_xml
  end
  
  def test_xml_simple_param_parsing
    authenticated_post_xml_to_context_create
    assert @controller.params.has_key?(:request)
    assert @controller.params[:request].has_key?(:context)
    assert @controller.params[:request][:context].has_key?(:name)
    assert_equal @@context_name, @controller.params[:request][:context][:name]
  end
  
  def test_fails_with_too_long_name
    invalid_with_long_name_postdata = "<request><context><name>foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfo barfoobarfoobarfoobarfoobarfoobarfoobar</name></context></request>"
    authenticated_post_xml_to_context_create invalid_with_long_name_postdata
    assert_response 409
    assert_xml_select 'errors' do
      assert_select 'error', 1, 'Name context name must be less than 256 characters'
    end
  end
  
  def test_fails_with_comma_in_name
    authenticated_post_xml_to_context_create "<request><context><name>foo,bar</name></context></request>"
    assert_response 409
    assert_xml_select 'errors' do
      assert_select 'error', 1, 'Name cannot contain the comma (\',\') character'
    end
  end
    
  def test_creates_new_context
    assert_difference 'Context.count' do
      authenticated_post_xml_to_context_create
      assert_response 201
    end
    context1 = Context.find_by_name(@@context_name)
    assert_not_nil context1, "expected context '#{@@context_name}' to be created"
  end
  
  private
    
  def authenticated_post_xml_to_context_create(postdata = @@valid_postdata, user = users(:other_user).login, password = 'sesame')
    authenticated_post_xml "/contexts", user, password, postdata
  end

  def assert_404_invalid_xml
    assert_response_and_body 400, "Expected post format is valid xml like so: <request><context><name>context name</name></context></request>."
  end
  
end
