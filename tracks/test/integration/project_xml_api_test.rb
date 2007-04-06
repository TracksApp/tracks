require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectXmlApiTest < ActionController::IntegrationTest
  fixtures :users, :projects

  @@project_name = "My New Project"
  @@valid_postdata = "<request><project><name>#{@@project_name}</name></project></request>"
  
  def setup
    assert_test_environment_ok
  end
  
  def test_fails_with_401_if_not_authorized_user
    authenticated_post_xml_to_project_create @@valid_postdata, 'nobody', 'nohow'
    assert_401_unauthorized
  end
  
 def test_fails_with_invalid_xml_format
   authenticated_post_xml_to_project_create "<foo></bar>"
   assert_404_invalid_xml
 end
    
  def test_fails_with_invalid_xml_format2
    authenticated_post_xml_to_project_create "<request><project></project></request>"
    assert_404_invalid_xml
  end
  
  def test_xml_simple_param_parsing
    authenticated_post_xml_to_project_create
    assert @controller.params.has_key?(:request)
    assert @controller.params[:request].has_key?(:project)
    assert @controller.params[:request][:project].has_key?(:name)
    assert_equal @@project_name, @controller.params[:request][:project][:name]
  end
  
  def test_fails_with_too_long_name
    invalid_with_long_name_postdata = "<request><project><name>foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfo barfoobarfoobarfoobarfoobarfoobarfoobar</name></project></request>"
    authenticated_post_xml_to_project_create invalid_with_long_name_postdata
    assert_response_and_body 404, "Name project name must be less than 256 characters"
  end
  
  def test_fails_with_comma_in_name
    authenticated_post_xml_to_project_create "<request><project><name>foo,bar</name></project></request>"
    assert_response_and_body 404, "Name cannot contain the comma (',') character"
  end
    
  def test_creates_new_project
    initial_count = Project.count
    authenticated_post_xml_to_project_create
    assert_response :success
    assert_xml_select 'project' do
      assert_xml_select "description"
      assert_xml_select 'id[type="integer"]', /[0-9]+/
      assert_xml_select 'name', @@project_name
      assert_xml_select 'position[type="integer"]', 1
      assert_xml_select 'state', 'active'
    end
    #assert_response_and_body_matches 200, %r|^<\?xml version="1\.0" encoding="UTF-8"\?>\n<project>\n  <description></description>\n  <id type=\"integer\">[0-9]+</id>\n  <name>#{@@project_name}</name>\n  <position type=\"integer\">1</position>\n  <state>active</state>\n</project>$|
    assert_equal initial_count + 1, Project.count
    project1 = Project.find_by_name(@@project_name)
    assert_not_nil project1, "expected project '#{@@project_name}' to be created"
  end
      
  private
    
  def authenticated_post_xml_to_project_create(postdata = @@valid_postdata, user = users(:other_user).login, password = 'sesame')
    authenticated_post_xml "/projects", user, password, postdata
  end

  def assert_404_invalid_xml
    assert_response_and_body 404, "Expected post format is valid xml like so: <request><project><name>project name</name></project></request>."
  end
  
end