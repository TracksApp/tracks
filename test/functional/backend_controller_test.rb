require File.dirname(__FILE__) + '/../test_helper'
require 'backend_controller'

# Re-raise errors caught by the controller.
class BackendController; def rescue_action(e) raise e end; end

class BackendControllerTest < ActionController::TestCase
  fixtures :users, :projects, :contexts, :todos, :recurring_todos, :notes
  
  def setup
    @controller = BackendController.new
    request, response = ActionController::TestRequest.new, ActionController::TestResponse.new
    assert_equal "change-me", Tracks::Config.salt
  end

  def test_new_todo_fails_with_incorrect_token
    assert_raises_invalid_token { @controller.new_todo('admin', 'notthecorrecttoken', contexts('agenda').id, 'test', 'test') }
  end
  
  def test_new_todo_fails_with_context_that_does_not_belong_to_user
     assert_raise(CannotAccessContext, "Cannot access a context that does not belong to this user.") { @controller.new_todo(users('other_user').login, users('other_user').token, contexts('agenda').id, 'test', 'test') }
  end
  
  def test_new_rich_todo_fails_with_incorrect_token
    assert_raises_invalid_token { @controller.new_rich_todo('admin', 'notthecorrecttoken', contexts('agenda').id, 'test', 'test') }
  end
  
  #"Call mfox @call > Build a working time machine" should create the "Call mfox" todo in the 'call' context and the 'Build a working time machine' project. 
  def test_new_rich_todo_creates_todo_with_exact_match
    assert_new_rich_todo_creates_mfox_todo("Call mfox @call > Build a working time machine")
  end

  #"Call mfox @cal > Build" should create the "Call mfox" todo in the 'call' context and the 'Build a working time machine' project. 
  def test_new_rich_todo_creates_todo_with_starts_with_match
    assert_new_rich_todo_creates_mfox_todo("Call mfox @cal > Build")
  end

  #"Call mfox @call > new:Run for president" should create the 'Run for president' project, create the "Call mfox" todo in the 'call' context and the new project. 
  def test_new_rich_todo_creates_todo_with_new_project
    max_todo_id = Todo.maximum('id')
    max_project_id = Project.maximum('id')
    @controller.new_rich_todo(users(:admin_user).login, users(:admin_user).token, contexts(:agenda).id, 'Call mfox @call > new:Run for president', 'test')
    todo = Todo.find(:first, :conditions => ["id > ?", max_todo_id])
    new_project = Project.find(:first, :conditions => ["id > ?", max_project_id])
    assert_equal(users(:admin_user).id, todo.user_id)
    assert_equal(contexts(:call).id, todo.context_id)
    assert_equal(new_project.id, todo.project_id)
    assert_equal("Call mfox", todo.description)
    assert_equal("test", todo.notes)
  end
  
  def assert_new_rich_todo_creates_mfox_todo(description_input)
    max_id = Todo.maximum('id')
    @controller.new_rich_todo(users(:admin_user).login, users(:admin_user).token, contexts(:agenda).id, 'Call mfox @cal > Build', 'test')
    todo = Todo.find(:first, :conditions => ["id > ?", max_id])
    assert_equal(users(:admin_user).id, todo.user_id)
    assert_equal(contexts(:call).id, todo.context_id)
    assert_equal(projects(:timemachine).id, todo.project_id)
    assert_equal('test', todo.notes)
    assert_equal("Call mfox", todo.description)
  end
  
  def test_new_rich_todo_fails_with_context_that_does_not_belong_to_user
     assert_raise(CannotAccessContext, "Cannot access a context that does not belong to this user.") { @controller.new_rich_todo(users('other_user').login, users('other_user').token, contexts('agenda').id, 'test', 'test') }
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
