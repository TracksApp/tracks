require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NotesControllerTest < ActionController::TestCase
  
  def setup
  end

  def test_get_notes_page
    login_as :admin_user
    get :index
    assert_response 200
  end
  
end
