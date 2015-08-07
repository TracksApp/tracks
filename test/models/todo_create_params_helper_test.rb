require 'test_helper'
require 'todos_controller'

class TodoCreateParamsHelperTest < ActiveSupport::TestCase

  def test_works_with_request_as_root_hash_entry
    params =  ActionController::Parameters.new({'request' => { 'todo' => { 'description' => 'foo'}}})
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal({'description' => 'foo'}, params_helper.attributes)
  end

  def test_works_with_todo_as_root_hash_entry
    params = ActionController::Parameters.new({ 'todo' => { 'description' => 'foo'}})
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal({'description' => 'foo'}, params_helper.attributes)
  end

  def test_show_from_accessor
    expected_date = Time.zone.now
    params =  ActionController::Parameters.new({ 'todo' => { 'show_from' => expected_date}})
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal(expected_date, params_helper.show_from)
  end

  def test_due_accessor
    expected_date = Time.zone.now
    params =  ActionController::Parameters.new({ 'todo' => { 'due' => expected_date}})
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal(expected_date, params_helper.due)
  end

  def test_tag_list_accessor
    params =  ActionController::Parameters.new({ 'todo' => { }, 'tag_list' => 'foo, bar'})
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal('foo, bar', params_helper.tag_list)
  end

  def test_parse_dates_parses_show_from_date_based_on_prefs
    params =  ActionController::Parameters.new({ 'todo' => { 'show_from' => '20/05/07', 'due' => '23/5/07'}})

    user = users(:admin_user)
    prefs = user.prefs
    prefs.date_format = "%d/%m/%y"  # make sure the format matches the above

    params_helper = Todos::TodoCreateParamsHelper.new(params, user)
    params_helper.parse_dates()
    assert_equal Date.new(2007, 5, 20), params_helper.show_from.to_date
  end

  def test_parse_dates_parses_due_date_based_on_prefs
    params =  ActionController::Parameters.new({ 'todo' => { 'show_from' => '20/5/07', 'due' => '23/5/07'}})

    user = users(:admin_user)
    prefs = user.prefs
    prefs.date_format = "%d/%m/%y"  # make sure the format matches the above

    params_helper = Todos::TodoCreateParamsHelper.new(params, user)
    params_helper.parse_dates()
    assert_equal Date.new(2007, 5, 23), params_helper.due.to_date
  end

  def test_parse_dates_sets_due_to_empty_string_if_nil
    params = ActionController::Parameters.new({ 'todo' => { 'show_from' => '20/5/07', 'due' => nil}})
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    params_helper.parse_dates()
    assert_equal '', params_helper.due
  end

  def test_project_name_is_stripped_of_leading_and_trailing_whitespace
    params = ActionController::Parameters.new({ 'project_name' => ' Visit New Orleans  ' })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal 'Visit New Orleans', params_helper.project_name
  end

  def test_project_name_is_nil_when_unspecified
    params =  ActionController::Parameters.new({ })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_nil params_helper.project_name
  end

  def test_context_name_is_stripped_of_leading_and_trailing_whitespace
    params = ActionController::Parameters.new({ 'context_name' => ' mobile phone  ' })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal 'mobile phone', params_helper.context_name
  end

  def test_context_name_is_nil_when_unspecified
    params = ActionController::Parameters.new({ })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_nil params_helper.context_name
  end

  def test_project_specified_by_name_is_false_when_project_id_is_specified
    params = ActionController::Parameters.new({ 'todo' => { 'project_id' => 2 } })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal false, params_helper.project_specified_by_name?
  end

  def test_project_specified_by_name_is_false_when_project_name_is_blank
    params = ActionController::Parameters.new({ 'project_name' => nil, 'todo' => {} })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal false, params_helper.project_specified_by_name?
  end

  def test_project_specified_by_name_is_false_when_project_name_is_blank_string
    params = ActionController::Parameters.new({ 'project_name' => '', 'todo' => {} })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal false, params_helper.project_specified_by_name?
  end

  def test_context_specified_by_name_is_false_when_context_id_is_specified
    params = ActionController::Parameters.new({ 'todo' => { 'context_id' => 3 } })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal false, params_helper.context_specified_by_name?
  end

  def test_context_specified_by_name_is_false_when_context_name_is_blank
    params = ActionController::Parameters.new({ 'context_name' => nil, 'todo' => {} })
    params_helper = Todos::TodoCreateParamsHelper.new(params, users(:admin_user))
    assert_equal false, params_helper.context_specified_by_name?
  end
end
