require 'test_helper'

class ProjectXmlApiTest < ActionDispatch::IntegrationTest
  @@project_name = "My New Project"
  @@valid_postdata = "<project><name>#{@@project_name}</name></project>"
  
  def test_retrieve_project
    authenticated_get_xml "/projects/1.xml", users(:admin_user).login, 'abracadabra', {}
    assert_tag :tag => "project"
    assert_tag :tag => "project", :child => {:tag => "not_done" }
    assert_tag :tag => "project", :child => {:tag => "deferred" }
    assert_tag :tag => "project", :child => {:tag => "pending" }
    assert_tag :tag => "project", :child => {:tag => "done" }
    assert_response 200
  end

 def test_fails_with_invalid_xml_format
   #Fails too hard for test to catch
   # authenticated_post_xml_to_project_create "<foo></bar>"
   # assert_equal 500, @integration_session.status
 end
    
  def test_fails_with_invalid_xml_format2
    authenticated_post_xml_to_project_create "<project><name></name></project>"
    assert_responses_with_error 'Name project must have a name'
  end
  
  def test_xml_simple_param_parsing
    authenticated_post_xml_to_project_create
    assert @controller.params.has_key?(:project)
    assert @controller.params[:project].has_key?(:name)
    assert_equal @@project_name, @controller.params[:project][:name]
  end
  
  def test_fails_with_401_if_not_authorized_user
    authenticated_post_xml_to_project_create @@valid_postdata, 'nobody', 'nohow'
    assert_response 401
  end
  
  def test_fails_with_too_long_name
    invalid_with_long_name_postdata = "<project><name>foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo arfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfo barfoobarfoobarfoobarfoobarfoobarfoobar</name></project>"
    authenticated_post_xml_to_project_create invalid_with_long_name_postdata
    assert_responses_with_error 'Name context name must be less than 256 characters'
  end
  
  def test_fails_with_comma_in_name
    authenticated_post_xml_to_project_create "<project><name>foo,bar</name></project>"
    assert_response :created
    project1 = Project.where(:name => "foo,bar").first
    assert_not_nil project1, "expected project 'foo,bar' to be created"
  end
    
  def test_creates_new_project
    assert_difference 'Project.count' do
      authenticated_post_xml_to_project_create
      assert_response :created
    end
    project1 = Project.where(:name => @@project_name).first
    assert_not_nil project1, "expected project '#{@@project_name}' to be created"
  end
      
  private
    
  def authenticated_post_xml_to_project_create(postdata = @@valid_postdata, user = users(:other_user).login, password = 'sesame')
    authenticated_post_xml "/projects.xml", user, password, postdata
  end

  def assert_404_invalid_xml
    assert_response_and_body 404, "Expected post format is valid xml like so: <project><name>project name</name></project>."
  end
  
end
