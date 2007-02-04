require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/todo_container_controller_test_base'
require 'contexts_controller'

# Re-raise errors caught by the controller.
class ContextsController; def rescue_action(e) raise e end; end

class ContextsControllerTest < TodoContainerControllerTestBase
  fixtures :users, :preferences, :contexts

  def setup
    perform_setup(Context, ContextsController)
  end

  def test_contexts_list
    @request.session['user_id'] = users(:admin_user).id
    get :index
  end

  def test_create_context_via_ajax_increments_number_of_context
    assert_ajax_create_increments_count '@newcontext'
  end

  def test_create_context_with_ajax_success_rjs
    ajax_create '@newcontext'
    assert_rjs :insert_html, :bottom, "list-contexts"
    assert_rjs :sortable, 'list-contexts', { :tag => 'div', :handle => 'handle', :complete => visual_effect(:highlight, 'list-contexts'), :url => order_contexts_path }
    # not yet sure how to write the following properly...
    assert_rjs :call, "Form.reset", "context-form"
    assert_rjs :call, "Form.focusFirstElement", "context-form"
  end

  def test_create_via_ajax_with_slash_in_name_does_not_increment_number_of_contexts
    assert_ajax_create_does_not_increment_count 'foo/bar'
  end
  
  def test_create_with_slash_in_name_fails_with_rjs
    ajax_create 'foo/bar'
    assert_rjs :show, 'status'
    assert_rjs :update, 'status', "<div class=\"ErrorExplanation\" id=\"ErrorExplanation\"><h2>1 error prohibited this record from being saved</h2><p>There were problems with the following fields:</p><ul>Name cannot contain the slash ('/') character</ul></div>"
  end

  def test_rss_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "rss" }
    assert_equal 'application/rss+xml; charset=utf-8', @response.headers["Content-Type"]
    #puts @response.body

    assert_xml_select 'rss[version="2.0"]' do
      assert_xml_select 'channel' do
        assert_xml_select '>title', 'Tracks Contexts'
        assert_xml_select '>description', "Lists all the contexts for #{users(:admin_user).display_name}."
        assert_xml_select 'language', 'en-us'
        assert_xml_select 'ttl', '40'
      end
      assert_xml_select 'item', 9 do
        assert_xml_select 'title', /.+/
        assert_xml_select 'description', /&lt;p&gt;\d+ actions. Context is (active|hidden). &lt;\/p&gt;/
        %w(guid link).each do |node|
          assert_xml_select node, /http:\/\/test.host\/contexts\/.+/
        end
        assert_xml_select 'pubDate', contexts(:agenda).created_at.to_s(:rfc822)
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
      assert_xml_select '>title', 'Tracks Contexts'
      assert_xml_select '>subtitle', "Lists all the contexts for #{users(:admin_user).display_name}."
      assert_xml_select 'entry', 3 do
        assert_xml_select 'title', /.+/
        assert_xml_select 'content[type="html"]', /&lt;p&gt;\d+ actions. Context is (active|hidden). &lt;\/p&gt;/
        assert_xml_select 'published', contexts(:agenda).created_at.to_s(:rfc822)
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
  
end
