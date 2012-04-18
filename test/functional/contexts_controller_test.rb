require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContextsControllerTest < ActionController::TestCase
  fixtures :users, :preferences, :contexts

  def test_contexts_list
    login_as :admin_user
    get :index
  end
  
  def test_show_sets_title
    login_as :admin_user
    get :show, { :id => "1" }
    assert_equal 'TRACKS::Context: agenda', assigns['page_title']
  end
  
  def test_show_renders_show_template
    login_as :admin_user
    get :show, { :id => "1" }
    assert_template "contexts/show"
  end

  def test_create_context_via_ajax_increments_number_of_context
    login_as :other_user
    assert_ajax_create_increments_count '@newcontext'
  end

  def test_create_via_ajax_with_comma_in_name_does_not_increment_number_of_contexts
    login_as :other_user
    assert_ajax_create_does_not_increment_count 'foo,bar'
  end


end
