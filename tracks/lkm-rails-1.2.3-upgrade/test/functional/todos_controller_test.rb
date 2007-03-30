require File.dirname(__FILE__) + '/../test_helper'
require 'todos_controller'

# Re-raise errors caught by the controller.
class TodosController; def rescue_action(e) raise e end; end

class TodosControllerTest < Test::Unit::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :tags, :taggings
  
  def setup
    @controller = TodosController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end
  
  def test_not_done_counts
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal 2, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 3, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal 1, assigns['context_not_done_counts'][contexts(:lab).id]
  end
  
  def test_not_done_counts_after_hiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal nil, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 2, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal nil, assigns['context_not_done_counts'][contexts(:lab).id]
  end
  
  def test_not_done_counts_after_hiding_and_unhiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    p.activate!
    p.save!
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal 2, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 3, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal 1, assigns['context_not_done_counts'][contexts(:lab).id]
  end
  
  def test_deferred_count_for_project_source_view
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :toggle_check, :id => 5, :_source_view => 'project' 
    assert_equal 1, assigns['deferred_count']
    xhr :post, :toggle_check, :id => 15, :_source_view => 'project' 
    assert_equal 0, assigns['deferred_count']
  end
  
  def test_destroy_todo
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :destroy, :id => 1, :_source_view => 'todo'
    assert_rjs :page, "todo_1", :remove
    #assert_rjs :replace_html, "badge-count", '9' 
  end
  
  def test_create_todo
    original_todo_count = Todo.count
    @request.session['user_id'] = users(:admin_user).id
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    assert_equal original_todo_count + 1, Todo.count
  end
  
  def test_create_deferred_todo
    original_todo_count = Todo.count
    @request.session['user_id'] = users(:admin_user).id
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2026", 'show_from' => '30/10/2026'}, "tag_list"=>"foo bar"
    assert_equal original_todo_count + 1, Todo.count
  end
  
  def test_update_todo_project
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    t = Todo.find(1)
    assert_equal 1, t.project_id
  end
  
  def test_update_todo_project_to_none
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"None", "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    t = Todo.find(1)
    assert_nil t.project_id
  end
  
  def test_update_todo
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "todo"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo, bar"
    t = Todo.find(1)
    assert_equal "Call Warren Buffet to find out how much he makes per day", t.description
    assert_equal "foo, bar", t.tag_list
    expected = Date.new(2006,11,30)
    actual = t.due
    assert_equal expected, actual, "Expected #{expected.to_s(:db)}, was #{actual.to_s(:db)}"
  end

  def test_update_todos_with_blank_project_name
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', :project_name => '', "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo, bar"
    t.reload
    assert t.project.nil?
  end
  
  def test_update_todo_tags_to_none
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "todo"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>""
    t = Todo.find(1)
    assert_equal true, t.tag_list.empty?
  end
  
  def test_find_tagged_with
    @request.session['user_id'] = users(:admin_user).id
    @user = User.find(@request.session['user_id'])
    tag = Tag.find_by_name('foo').todos
    @tagged = tag.find(:all, :conditions => ['taggings.user_id = ?', @user.id]).size
    get :tag, :name => 'foo'
    assert_response :success
    assert_equal 3, @tagged
  end

  def test_find_tagged_withd_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "rss" }
    assert_equal 'application/rss+xml; charset=utf-8', @response.headers["Content-Type"]
    #puts @response.body

    assert_xml_select 'rss[version="2.0"]' do
      assert_select 'channel' do
        assert_select '>title', 'Tracks Actions'
        assert_select '>description', "Actions for #{users(:admin_user).display_name}"
        assert_select 'language', 'en-us'
        assert_select 'ttl', '40'
        assert_select 'item', 10 do
          assert_select 'title', /.+/
          assert_select 'description', /.*/
          %w(guid link).each do |node|
            assert_select node, /http:\/\/test.host\/contexts\/.+/
          end
          assert_select 'pubDate', projects(:timemachine).updated_at.to_s(:rfc822)
        end
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
      assert_xml_select '>title', 'Tracks Actions'
      assert_xml_select '>subtitle', "Actions for #{users(:admin_user).display_name}"
      assert_xml_select 'entry', 10 do
        assert_xml_select 'title', /.+/
        assert_xml_select 'content[type="html"]', /.*/
        assert_xml_select 'published', /(#{projects(:timemachine).updated_at.xmlschema}|#{projects(:moremoney).updated_at.xmlschema})/
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

  def test_ical_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "ics" }
    assert_equal 'text/calendar; charset=utf-8', @response.headers["Content-Type"]
    assert !(/&nbsp;/.match(@response.body))
    #puts @response.body
  end

end
