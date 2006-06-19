require File.dirname(__FILE__) + '/../test_helper'
require 'project_controller'

# Re-raise errors caught by the controller.
class ProjectController; def rescue_action(e) raise e end; end

class ProjectControllerTest < Test::Unit::TestCase
  fixtures :users, :projects
  
  def setup
    @controller = ProjectController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_create_project
    num_projects = Project.count
    @request.session['user_id'] = users(:other_user).id
    xhr :post, :new_project, :project => {:name => 'My New Project'}
    assert_rjs :hide, "warning"
    assert_rjs :insert_html, :bottom, "list-projects"
    assert_rjs :sortable, 'list-projects', { :tag => 'div', :handle => 'handle', :complete => visual_effect(:highlight, 'list-projects'), :url => {:controller => 'project', :action => 'order'} }
    # not yet sure how to write the following properly...
    assert_rjs :call, "Form.reset", "project-form"
    assert_rjs :call, "Form.focusFirstElement", "project-form"
    assert_equal num_projects + 1, Project.count
  end

  def test_create_with_slash_in_name_fails
    num_projects = Project.count
    @request.session['user_id'] = users(:other_user).id
    xhr :post, :new_project, :project => {:name => 'foo/bar'}
    assert_rjs :hide, "warning"
    assert_rjs :replace_html, 'warning', "<div class=\"ErrorExplanation\" id=\"ErrorExplanation\"><h2>1 error prohibited this record from being saved</h2><p>There were problems with the following fields:</p><ul>Name cannot contain the slash ('/') character</ul></div>"
    assert_rjs :visual_effect, :appear, "warning", :duration => '0.5'    
    assert_equal num_projects, Project.count
  end
end
