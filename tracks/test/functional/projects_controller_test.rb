require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/todo_container_controller_test_base'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < TodoContainerControllerTestBase
  fixtures :users, :todos, :preferences, :projects, :contexts
  
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
    get :show, :id => p.to_param
    assert_not_nil assigns['deferred']
    assert_equal 1, assigns['deferred'].size

    t = p.not_done_todos[0]
    t.show_from = 1.days.from_now.utc.to_date
    t.save!
    
    get :show, :id => p.to_param
    assert_equal 2, assigns['deferred'].size
  end

  def test_create_project_via_ajax_increments_number_of_projects
    assert_ajax_create_increments_count 'My New Project'
  end

  def test_create_project_with_ajax_success_rjs
    ajax_create 'My New Project'
    assert_rjs :insert_html, :bottom, "list-projects"
    assert_rjs :sortable, 'list-projects', { :tag => 'div', :handle => 'handle', :complete => visual_effect(:highlight, 'list-projects'), :url => order_projects_path }
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
  
  def test_rss_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "rss" }
    assert_equal 'application/rss+xml; charset=utf-8', @response.headers["Content-Type"]
    #puts @response.body

    assert_xml_select 'rss[version="2.0"]' do
      assert_xml_select 'channel' do
        assert_xml_select '>title', 'Tracks Projects'
        assert_xml_select '>description', "Lists all the projects for #{users(:admin_user).display_name}."
        assert_xml_select 'language', 'en-us'
        assert_xml_select 'ttl', '40'
      end
      assert_xml_select 'item', 3 do
        assert_xml_select 'title', /.+/
        assert_xml_select 'description', /&lt;p&gt;\d+ actions. Project is (active|hidden|completed). &lt;\/p&gt;/
        %w(guid link).each do |node|
          assert_xml_select node, /http:\/\/test.host\/projects\/.+/
        end
        assert_xml_select 'pubDate', /(#{projects(:timemachine).updated_at.to_s(:rfc822)}|#{projects(:moremoney).updated_at.to_s(:rfc822)}})/
      end
    end
  end
    
  def test_rss_feed_not_accessible_to_anonymous_user_without_token
    @request.session['user_id'] = nil
    get :index, { :format => "rss" }
    assert_response 401
  end
  
  def test_rss_feed_not_accessible_to_anonymous_user_with_invalid_token
    @request.session['user_id'] = nil
    get :index, { :format => "rss", :token => 'foo'  }
    assert_response 401
  end
  
  def test_rss_feed_accessible_to_anonymous_user_with_valid_token
    @request.session['user_id'] = nil
    get :index, { :format => "rss", :token => users(:admin_user).word }
    assert_response :ok
  end
  
  def test_atom_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "atom" }
    assert_equal 'application/atom+xml; charset=utf-8', @response.headers["Content-Type"]
    #puts @response.body
    
    assert_xml_select 'feed[xmlns="http://www.w3.org/2005/Atom"]' do
      assert_xml_select '>title', 'Tracks Projects'
      assert_xml_select '>subtitle', "Lists all the projects for #{users(:admin_user).display_name}."
      assert_xml_select 'entry', 3 do
        assert_xml_select 'title', /.+/
        assert_xml_select 'content[type="html"]', /&lt;p&gt;\d+ actions. Project is (active|hidden|completed). &lt;\/p&gt;/
        assert_xml_select 'published', /(#{projects(:timemachine).updated_at.to_s(:rfc822)}|#{projects(:moremoney).updated_at.to_s(:rfc822)}})/
      end
    end
  end
  
  def test_atom_feed_not_accessible_to_anonymous_user_without_token
    @request.session['user_id'] = nil
    get :index, { :format => "atom" }
    assert_response 401
  end
  
  def test_atom_feed_not_accessible_to_anonymous_user_with_invalid_token
    @request.session['user_id'] = nil
    get :index, { :format => "atom", :token => 'foo'  }
    assert_response 401
  end
  
  def test_atom_feed_accessible_to_anonymous_user_with_valid_token
    @request.session['user_id'] = nil
    get :index, { :format => "atom", :token => users(:admin_user).word }
    assert_response :ok
  end

  def test_text_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "txt" }
    assert_equal 'text/plain; charset=utf-8', @response.headers["Content-Type"]
    assert !(/&nbsp;/.match(@response.body)) 
    #puts @response.body
  end
  
  def test_text_feed_content_for_projects_with_no_actions
    @request.session['user_id'] = users(:admin_user).id
    p = projects(:timemachine)
    p.todos.each { |t| t.destroy }
    
    get :index, { :format => "txt", :only_active_with_no_next_actions => true }
    assert (/^\s*BUILD A WORKING TIME MACHINE\s+0 actions. Project is active.\s*$/.match(@response.body)) 
    assert !(/[1-9] actions/.match(@response.body)) 
  end
  
  def test_text_feed_not_accessible_to_anonymous_user_without_token
    @request.session['user_id'] = nil
    get :index, { :format => "txt" }
    assert_response 401
  end
  
  def test_text_feed_not_accessible_to_anonymous_user_with_invalid_token
    @request.session['user_id'] = nil
    get :index, { :format => "txt", :token => 'foo'  }
    assert_response 401
  end
  
  def test_text_feed_accessible_to_anonymous_user_with_valid_token
    @request.session['user_id'] = nil
    get :index, { :format => "txt", :token => users(:admin_user).word }
    assert_response :ok
  end
  
end
