require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'notes_controller'

# Re-raise errors caught by the controller.
class NotesController; def rescue_action(e) raise e end; end

class NotesControllerTest < ActionController::TestCase
  def setup
    @controller = NotesController.new
    request    = ActionController::TestRequest.new
    response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
