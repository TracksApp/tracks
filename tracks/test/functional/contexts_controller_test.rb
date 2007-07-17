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

  def test_create_via_ajax_with_comma_in_name_does_not_increment_number_of_contexts
    assert_ajax_create_does_not_increment_count 'foo,bar'
  end
  
  def test_create_with_comma_in_name_fails_with_rjs
    ajax_create 'foo,bar'
    assert_rjs :show, 'status'
    assert_rjs :update, 'status', "<div class=\"ErrorExplanation\" id=\"ErrorExplanation\"><h2>1 error prohibited this record from being saved</h2><p>There were problems with the following fields:</p><ul>Name cannot contain the comma (',') character</ul></div>"
  end

  def test_rss_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "rss" }
    assert_equal 'application/rss+xml; charset=utf-8', @response.headers["Content-Type"]
    #puts @response.body

    assert_xml_select 'rss[version="2.0"]' do
      assert_select 'channel' do
        assert_select '>title', 'Tracks Contexts'
        assert_select '>description', "Lists all the contexts for #{users(:admin_user).display_name}"
        assert_select 'language', 'en-us'
        assert_select 'ttl', '40'
      end
      assert_select 'item', 10 do
        assert_select 'title', /.+/
        assert_select 'description' do
          assert_select_encoded do
            assert_select 'p', /\d+&nbsp;actions. Context is (Active|Hidden)./
          end
        end
        %w(guid link).each do |node|
          assert_select node, /http:\/\/test.host\/contexts\/.+/
        end
        assert_select 'pubDate', contexts(:agenda).created_at.to_s(:rfc822)
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
    get :index, { :format => "rss", :token => users(:admin_user).token }
    assert_response :ok
  end
  
  def test_atom_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "atom" }
    assert_equal 'application/atom+xml; charset=utf-8', @response.headers["Content-Type"]
    #puts @response.body
    
    assert_xml_select 'feed[xmlns="http://www.w3.org/2005/Atom"]' do
      assert_select '>title', 'Tracks Contexts'
      assert_select '>subtitle', "Lists all the contexts for #{users(:admin_user).display_name}"
      assert_select 'entry', 10 do
        assert_select 'title', /.+/
        assert_select 'content[type="html"]' do
          assert_select_encoded do
            assert_select 'p', /\d+&nbsp;actions. Context is (Active|Hidden)./
          end
        end
        assert_select 'published', /(#{contexts(:agenda).created_at.xmlschema}|#{contexts(:library).created_at.xmlschema})/
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
    get :index, { :format => "atom", :token => users(:admin_user).token }
    assert_response :ok
  end
 
  def test_text_feed_content
    @request.session['user_id'] = users(:admin_user).id
    get :index, { :format => "txt" }
    assert_equal 'text/plain; charset=utf-8', @response.headers["Content-Type"]
    assert !(/&nbsp;/.match(@response.body)) 
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
    get :index, { :format => "txt", :token => users(:admin_user).token }
    assert_response :ok
  end
  
  def test_show_sets_title
    @request.session['user_id'] = users(:admin_user).id
    get :show, { :id => "1" }
    assert_equal 'TRACKS::Context: agenda', assigns['page_title']
  end
  
  def test_show_renders_show_template
    @request.session['user_id'] = users(:admin_user).id
    get :show, { :id => "1" }
    assert_template "contexts/show"
  end
  
  def test_show_xml_renders_context_to_xml
    @request.session['user_id'] = users(:admin_user).id
    get :show, { :id => "1", :format => 'xml' }
    assert_equal contexts(:agenda).to_xml( :except => :user_id ), @response.body
  end
  
  def test_show_with_nil_context_returns_404
    @request.session['user_id'] = users(:admin_user).id
    get :show, { :id => "0" }
    assert_equal 'Context not found', @response.body 
    assert_response 404
  end
  
  def test_show_xml_with_nil_context_returns_404
    @request.session['user_id'] = users(:admin_user).id
    get :show, { :id => "0", :format => 'xml' }
    assert_response 404
    assert_xml_select 'error', 'Context not found'
  end
  
end
