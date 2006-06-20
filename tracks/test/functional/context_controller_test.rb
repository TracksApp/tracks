require File.dirname(__FILE__) + '/../test_helper'
require 'context_controller'

# Re-raise errors caught by the controller.
class ContextController; def rescue_action(e) raise e end; end

class ContextControllerTest < Test::Unit::TestCase
  fixtures :users, :contexts

  def setup
    @controller = ContextController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_create_context
    num_contexts = Context.count
    @request.session['user_id'] = users(:other_user).id
    xhr :post, :new_context, :context => {:name => 'newcontext'}
    assert_rjs :hide, "warning"
    assert_rjs :insert_html, :bottom, "list-contexts"
    assert_rjs :sortable, 'list-contexts', { :tag => 'div', :handle => 'handle', :complete => visual_effect(:highlight, 'list-contexts'), :url => {:controller => 'context', :action => 'order'} }
    # not yet sure how to write the following properly...
    assert_rjs :call, "Form.reset", "context-form"
    assert_rjs :call, "Form.focusFirstElement", "context-form"
    assert_equal num_contexts + 1, Context.count
  end

  def test_create_with_slash_in_name_fails
    num_contexts = Context.count
    @request.session['user_id'] = users(:other_user).id
    xhr :post, :new_context, :context => {:name => 'foo/bar'}
    assert_rjs :hide, "warning"
    assert_rjs :replace_html, 'warning', "<div class=\"ErrorExplanation\" id=\"ErrorExplanation\"><h2>1 error prohibited this record from being saved</h2><p>There were problems with the following fields:</p><ul>Name cannot contain the slash ('/') character</ul></div>"
    assert_rjs :visual_effect, :appear, "warning", :duration => '0.5'    
    assert_equal num_contexts, Context.count
  end

end
