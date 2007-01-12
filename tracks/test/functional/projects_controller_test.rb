require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/todo_container_controller_test_base'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < TodoContainerControllerTestBase
  fixtures :users, :todos, :preferences, :projects
  
  def setup
    perform_setup(Project, ProjectsController)
  end
  
  def test_projects_list
    @request.session['user_id'] = users(:admin_user).id
    get :index
  end
  
  def test_show_exposes_deferred_todos
    @request.session['user_id'] = users(:admin_user).id
    p = projects(:timemachine)
    get :show, :url_friendly_name => p.url_friendly_name
    assert_not_nil assigns['deferred']
    assert_equal 1, assigns['deferred'].size

    t = p.not_done_todos[0]
    t.show_from = 1.days.from_now.utc.to_date
    t.save!
    
    get :show, :url_friendly_name => p.url_friendly_name
    assert_equal 2, assigns['deferred'].size
  end

  def test_create_project_via_ajax_increments_number_of_projects
    assert_ajax_create_increments_count 'My New Project'
  end

  def test_create_project_with_ajax_success_rjs
    ajax_create 'My New Project'
    assert_rjs :insert_html, :bottom, "list-projects"
    assert_rjs :sortable, 'list-projects', { :tag => 'div', :handle => 'handle', :complete => visual_effect(:highlight, 'list-projects'), :url => {:controller => 'project', :action => 'order'} }
    # not yet sure how to write the following properly...
    assert_rjs :call, "Form.reset", "project-form"
    assert_rjs :call, "Form.focusFirstElement", "project-form"
  end

  def test_create_with_slash_in_name_does_not_increment_number_of_projects
    assert_ajax_create_does_not_increment_count 'foo/bar'
  end
  
  def test_create_with_slash_in_name_fails_with_rjs
    ajax_create 'foo/bar'
    assert_rjs :show, 'status'
    assert_rjs :update, 'status', "<div class=\"ErrorExplanation\" id=\"ErrorExplanation\"><h2>1 error prohibited this record from being saved</h2><p>There were problems with the following fields:</p><ul>Name cannot contain the slash ('/') character</ul></div>"
  end
  
  def test_todo_state_is_project_hidden_after_hiding_project
    p = projects(:timemachine)
    todos = p.todos.find_in_state(:all, :active)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, "project"=>{"name"=>p.name, "description"=>p.description, "state"=>"hidden"}
    todos.each do |t|
      assert_equal :project_hidden, t.reload().current_state
    end
    assert p.reload().hidden?
  end
  
  def test_not_done_counts_after_hiding_and_unhiding_project
    p = projects(:timemachine)
    todos = p.todos.find_in_state(:all, :active)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, "project"=>{"name"=>p.name, "description"=>p.description, "state"=>"hidden"}
    xhr :post, :update, :id => 1, "project"=>{"name"=>p.name, "description"=>p.description, "state"=>"active"}
    todos.each do |t|
      assert_equal :active, t.reload().current_state
    end
    assert p.reload().active?
  end
  
  
end
