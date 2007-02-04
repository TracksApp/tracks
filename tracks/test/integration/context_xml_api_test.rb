require File.dirname(__FILE__) + '/../test_helper'
require 'contexts_controller'

# Re-raise errors caught by the controller.
class ContextsController; def rescue_action(e) raise e end; end

class ContextXmlApiTest < ActionController::IntegrationTest
  fixtures :users, :contexts

  @@context_name = "@newcontext"
  @@valid_postdata = "<request><context><name>#{@@context_name}</name></context></request>"
  
  def setup
    assert_test_environment_ok
  end
  
  def test_fails_with_401_if_not_authorized_user
    authenticated_post_xml_to_context_create @@valid_postdata, 'nobody', 'nohow'
    assert_401_unauthorized
  end
  
 def test_fails_with_invalid_xml_format
   authenticated_post_xml_to_context_create "<foo></bar>"
   assert_404_invalid_xml
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
    assert_response_and_body 404, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <error>Name context name must be less than 256 characters</error>\n</errors>\n"
  end
  
  def test_fails_with_slash_in_name
    authenticated_post_xml_to_context_create "<request><context><name>foo/bar</name></context></request>"
    assert_response_and_body 404, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <error>Name cannot contain the slash ('/') character</error>\n</errors>\n"
  end
    
  def test_creates_new_context
    initial_count = Context.count
    authenticated_post_xml_to_context_create
    assert_response_and_body_matches 200, %r|^<\?xml version="1.0" encoding="UTF-8"\?>\n<context>\n  <created-at type=\"datetime\">\d{4}+-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z</created-at>\n  <hide type="integer">0</hide>\n  <id type="integer">\d+</id>\n  <name>#{@@context_name}</name>\n  <position type="integer">1</position>\n  <updated-at type=\"datetime\">\d{4}+-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z</updated-at>\n</context>\n$|
    assert_equal initial_count + 1, Context.count
    context1 = Context.find_by_name(@@context_name)
    assert_not_nil context1, "expected context '#{@@context_name}' to be created"
  end
  
  private
    
  def authenticated_post_xml_to_context_create(postdata = @@valid_postdata, user = users(:other_user).login, password = 'sesame')
    authenticated_post_xml "/contexts", user, password, postdata
  end

  def assert_404_invalid_xml
    assert_response_and_body 404, "Expected post format is valid xml like so: <request><context><name>context name</name></context></request>."
  end
  
end