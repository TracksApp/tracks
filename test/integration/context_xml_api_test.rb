require 'test_helper'

class ContextXmlApiTest < ActionDispatch::IntegrationTest

  @@context_name = "@newcontext"
  @@valid_postdata = "<context><name>#{@@context_name}</name></context>"
  
  # def test_fails_with_invalid_xml_format
  #    # Fails too hard for test to catch
  #    authenticated_post_xml_to_context_create "<foo></bar>"
  #    assert_response 500
  # end
    
  def test_xml_simple_param_parsing
    authenticated_post_xml_to_context_create
    assert @controller.params.has_key?(:context)
    assert @controller.params[:context].has_key?(:name)
    assert_equal @@context_name, @controller.params[:context][:name]
  end
  
  def test_fails_gracefully_with_invalid_xml_format
    authenticated_post_xml_to_context_create "<context><name></name></context>"
    assert_responses_with_error 'Name context must have a name'
  end
    
  def test_fails_with_too_long_name
    invalid_with_long_name_postdata = "<context><name>foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfo barfoobarfoobarfoobarfoobarfoobarfoobar</name></context>"
    authenticated_post_xml_to_context_create invalid_with_long_name_postdata
    assert_responses_with_error 'Name context name must be less than 256 characters'
  end
  
  def test_fails_with_401_if_not_authorized_user
    authenticated_post_xml_to_context_create @@valid_postdata, 'nobody', 'nohow'
    assert_response 401
  end
  
  def test_creates_new_context
    assert_difference 'Context.count' do
      authenticated_post_xml_to_context_create
      assert_response 201
    end
    context1 = Context.where(:name => @@context_name).first
    assert_not_nil context1, "expected context '#{@@context_name}' to be created"
  end
  
  private
    
  def authenticated_post_xml_to_context_create(postdata = @@valid_postdata, user = users(:other_user).login, password = 'sesame')
    authenticated_post_xml "/contexts.xml", user, password, postdata
  end

end
