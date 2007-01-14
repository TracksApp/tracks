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
  
end
