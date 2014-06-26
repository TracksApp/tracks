require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  
  def test_get_notes_page
    login_as :admin_user
    get :index
    assert_response 200
  end

  def test_create_new_note
    login_as :admin_user
    project = users(:admin_user).projects.first
    count = users(:admin_user).notes.count

  	post :create, note: {body: "test note", project_id: project.id}, format: :js

  	assert_response 200
  	assert assigns['saved'], "@saved should be true"
  	assert count+1, users(:admin_user).notes.reload.count
  end

  def test_update_note
  	login_as :admin_user

  	note = users(:admin_user).notes.first

  	assert_not_equal "test", note.body
  	post :update, id: note.id, note: {body: "test"}, format: :js
  	assert_equal "test", note.reload.body
  end

  def test_destroy_note
  	login_as :admin_user

  	note = users(:admin_user).notes.first
    count = users(:admin_user).notes.count

    post :destroy, id: note.id, format: :js

    old_note = users(:admin_user).notes.where(id: note.id).first
    assert_nil old_note
    assert count-1, users(:admin_user).notes.reload.count
  end
  
end
