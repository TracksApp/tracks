require File.dirname(__FILE__) + '/../test_helper'
require 'backend_controller'

# Re-raise errors caught by the controller.
class BackendController; def rescue_action(e) raise e end; end

class BackendControllerTest < Test::Unit::TestCase
  fixtures :users, :projects, :contexts, :todos, :notes
  
  def setup
    @controller = BackendController.new
    request, response = ActionController::TestRequest.new, ActionController::TestResponse.new
    assert_equal "change-me", User.get_salt()
  end

  def test_new_todo_fails_with_incorrect_token
    assert_raises_invalid_token { @controller.new_todo('admin', 'notthecorrecttoken', contexts('agenda').id, 'test') }
  end
  
  def test_new_todo_fails_with_context_that_does_not_belong_to_user
     assert_raise(CannotAccessContext, "Cannot access a context that does not belong to this user.") { @controller.new_todo(users('other_user').login, users('other_user').word, contexts('agenda').id, 'test') }
  end

  def test_list_projects_fails_with_incorrect_token
    assert_raises_invalid_token { @controller.list_projects('admin', 'notthecorrecttoken') }
  end

  def test_list_contexts_fails_with_incorrect_token
    assert_raises_invalid_token { @controller.list_contexts('admin', 'notthecorrecttoken') }
  end
  
  private
  
  def assert_raises_invalid_token
    assert_raise(InvalidToken, "Sorry, you don't have permission to perform this action.") { yield } 
  end

end
