require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/todo_container_controller_test_base'
require 'context_controller'

# Re-raise errors caught by the controller.
class ContextController; def rescue_action(e) raise e end; end

class ContextControllerTest < TodoContainerControllerTestBase
  fixtures :users, :contexts

  def setup
    perform_setup(Context, ContextController)
  end

  def test_create_context_via_ajax_increments_number_of_context
    assert_ajax_create_increments_count '@newcontext'
  end

  def test_create_context_with_ajax_success_rjs
    ajax_create '@newcontext'
    assert_rjs :hide, "warning"
    assert_rjs :insert_html, :bottom, "list-contexts"
    assert_rjs :sortable, 'list-contexts', { :tag => 'div', :handle => 'handle', :complete => visual_effect(:highlight, 'list-contexts'), :url => {:controller => 'context', :action => 'order'} }
    # not yet sure how to write the following properly...
    assert_rjs :call, "Form.reset", "context-form"
    assert_rjs :call, "Form.focusFirstElement", "context-form"
  end

  def test_create_via_ajax_with_slash_in_name_does_not_increment_number_of_contexts
    assert_ajax_create_does_not_increment_count 'foo/bar'
  end
  
  def test_create_with_slash_in_name_fails_with_rjs
    ajax_create 'foo/bar'
    assert_rjs :hide, "warning"
    assert_rjs :replace_html, 'warning', "<div class=\"ErrorExplanation\" id=\"ErrorExplanation\"><h2>1 error prohibited this record from being saved</h2><p>There were problems with the following fields:</p><ul>Name cannot contain the slash ('/') character</ul></div>"
    assert_rjs :visual_effect, :appear, "warning", :duration => '0.5'    
  end
  
end
