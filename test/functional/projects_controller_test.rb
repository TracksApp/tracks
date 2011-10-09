require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/todo_container_controller_test_base')
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < TodoContainerControllerTestBase
  fixtures :users, :todos, :preferences, :projects, :contexts, :recurring_todos
  
  def setup
    perform_setup(Project, ProjectsController)
  end
  
  def test_projects_list
    login_as :admin_user
    get :index
  end
  
  def test_show_exposes_deferred_todos
    p = projects(:timemachine)
    login_as :admin_user
    get :show, :id => p.to_param
    assert_not_nil assigns['deferred']
    assert_equal 1, assigns['deferred'].size

    t = p.todos.not_completed[0]
    t.show_from = 1.days.from_now.utc
    t.save!
    
    get :show, :id => p.to_param
    assert_equal 2, assigns['deferred'].size
  end

  def test_show_exposes_next_project_in_same_state
    login_as :admin_user
    get :show, :id => projects(:timemachine).to_param
    assert_equal(projects(:moremoney), assigns['next_project'])
  end

  def test_show_exposes_previous_project_in_same_state
    login_as :admin_user
    get :show, :id => projects(:moremoney).to_param
    assert_equal(projects(:timemachine), assigns['previous_project'])
  end

  def test_create_project_via_ajax_increments_number_of_projects
    assert_ajax_create_increments_count 'My New Project'
  end

  def test_create_with_comma_in_name_increments_number_of_projects
    assert_ajax_create_increments_count 'foo,bar'
  end
  
  def test_todo_state_is_project_hidden_after_hiding_project
    p = projects(:timemachine)
    todos = p.todos.find_in_state(:all, :active)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, "project"=>{"name"=>p.name, "description"=>p.description, "state"=>"hidden"}
    todos.each do |t|
      assert_equal :project_hidden, t.reload().aasm_current_state
    end
    assert p.reload().hidden?
  end
  
  def test_not_done_counts_after_hiding_and_unhiding_project
    p = projects(:timemachine)
    todos = p.todos.find_in_state(:all, :active)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, "project"=>{"name"=>p.name, "description"=>p.description, "state"=>"hidden"}
    xhr :post, :update, :id => 1, "project"=>{"name"=>p.name, "description"=>p.description, "state"=>"active"}
    todos.each do |t|
      assert_equal :active, t.reload().aasm_current_state
    end
    assert p.reload().active?
  end
  
  def test_rss_feed_content
    login_as(:admin_user)
    get :index, { :format => "rss" }
    assert_equal 'application/rss+xml', @response.content_type
    #puts @response.body

    assert_xml_select 'rss[version="2.0"]' do
      assert_select 'channel' do
        assert_select '>title', 'Tracks Projects'
        assert_select '>description', "Lists all the projects for #{users(:admin_user).display_name}"
        assert_select 'language', 'en-us'
        assert_select 'ttl', '40'
      end
      assert_select 'item', 3 do
        assert_select 'title', /.+/
        assert_select 'description' do
          assert_select_encoded do
            assert_select 'p', /^\d+&nbsp;actions\. Project is (active|hidden|completed)\.$/
          end
        end
        %w(guid link).each do |node|
          assert_select node, /http:\/\/test.host\/projects\/.+/
        end
        assert_select 'pubDate', projects(:timemachine).updated_at.to_s(:rfc822)
      end
    end
  end
    
  def test_rss_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :index, { :format => "rss" }
    assert_response 401
  end
  
  def test_rss_feed_not_accessible_to_anonymous_user_with_invalid_token
    login_as nil
    get :index, { :format => "rss", :token => 'foo'  }
    assert_response 401
  end
  
  def test_rss_feed_accessible_to_anonymous_user_with_valid_token
    login_as nil
    get :index, { :format => "rss", :token => users(:admin_user).token }
    assert_response :ok
  end
  
  def test_atom_feed_content
    login_as :admin_user
    get :index, { :format => "atom" }
    assert_equal 'application/atom+xml', @response.content_type
    #puts @response.body
    
    assert_xml_select 'feed[xmlns="http://www.w3.org/2005/Atom"]' do
      assert_select '>title', 'Tracks Projects'
      assert_select '>subtitle', "Lists all the projects for #{users(:admin_user).display_name}"
      assert_select 'entry', 3 do
        assert_select 'title', /.+/
        assert_select 'content[type="html"]' do
          assert_select_encoded do
            assert_select 'p', /\d+&nbsp;actions. Project is (active|hidden|completed)./
          end
        end
        assert_select 'published', /(#{Regexp.escape(projects(:timemachine).updated_at.xmlschema)}|#{Regexp.escape(projects(:moremoney).updated_at.xmlschema)})/
      end
    end
  end
  
  def test_atom_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :index, { :format => "atom" }
    assert_response 401
  end
  
  def test_atom_feed_not_accessible_to_anonymous_user_with_invalid_token
    login_as nil
    get :index, { :format => "atom", :token => 'foo'  }
    assert_response 401
  end
  
  def test_atom_feed_accessible_to_anonymous_user_with_valid_token
    login_as nil
    get :index, { :format => "atom", :token => users(:admin_user).token }
    assert_response :ok
  end

  def test_text_feed_content
    login_as :admin_user
    get :index, { :format => "txt" }
    assert_equal 'text/plain', @response.content_type
    assert !(/&nbsp;/.match(@response.body))
  end
  
  def test_text_feed_content_for_projects_with_no_actions
    login_as :admin_user
    p = projects(:timemachine)
    p.todos.each { |t| t.destroy }
    
    get :index, { :format => "txt", :only_active_with_no_next_actions => true }
    assert (/^\s*BUILD A WORKING TIME MACHINE\s+0 actions. Project is active.\s*$/.match(@response.body)) 
    assert !(/[1-9] actions/.match(@response.body)) 
  end
  
  def test_text_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :index, { :format => "txt" }
    assert_response 401
  end
  
  def test_text_feed_not_accessible_to_anonymous_user_with_invalid_token
    login_as nil
    get :index, { :format => "txt", :token => 'foo'  }
    assert_response 401
  end
  
  def test_text_feed_accessible_to_anonymous_user_with_valid_token
    login_as nil
    get :index, { :format => "txt", :token => users(:admin_user).token }
    assert_response :ok
  end

  def test_actionize_sorts_active_projects_by_number_of_tasks
    login_as :admin_user
    u = users(:admin_user)
    post :actionize, :state => "active", :format => 'js'
    
    assert_equal 1, projects(:gardenclean).position
    assert_equal 2, projects(:moremoney).position
    assert_equal 3, projects(:timemachine).position
  end
  
  def test_alphabetize_sorts_active_projects_alphabetically
    login_as :admin_user
    u = users(:admin_user)
    post :alphabetize, :state => "active", :format => 'js'
    assert_equal 1, projects(:timemachine).position
    assert_equal 2, projects(:gardenclean).position
    assert_equal 3, projects(:moremoney).position 
  end

  def test_alphabetize_assigns_state
    login_as :admin_user
    post :alphabetize, :state => "active", :format => 'js'
    assert_equal "active", assigns['state']
  end

  def test_alphabetize_assigns_projects
    login_as :admin_user
    post :alphabetize, :state => "active", :format => 'js'
    exposed_projects = assigns['projects']
    assert_equal 3, exposed_projects.length
    assert_equal projects(:timemachine), exposed_projects[0]
    assert_equal projects(:gardenclean), exposed_projects[1]
    assert_equal projects(:moremoney), exposed_projects[2]
  end
  
  def protect_against_forgery?
    false
  end
end
