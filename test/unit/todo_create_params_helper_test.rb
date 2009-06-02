require File.dirname(__FILE__) + '/../test_helper'
require 'todos_controller'

class TodoCreateParamsHelperTest < ActiveSupport::TestCase

  def test_works_with_request_as_root_hash_entry
    params = {'request' => { 'todo' => { 'description' => 'foo'}}}
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal({'description' => 'foo'}, params_helper.attributes)
  end

  def test_works_with_todo_as_root_hash_entry
    params = { 'todo' => { 'description' => 'foo'}}
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal({'description' => 'foo'}, params_helper.attributes)
  end
  
  def test_show_from_accessor
    expected_date = Time.now
    params = { 'todo' => { 'show_from' => expected_date}}
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal(expected_date, params_helper.show_from)
  end
  
  def test_due_accessor
    expected_date = Time.now
    params = { 'todo' => { 'due' => expected_date}}
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal(expected_date, params_helper.due)
  end
  
  def test_tag_list_accessor
    params = { 'todo' => { }, 'tag_list' => 'foo, bar'}
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal('foo, bar', params_helper.tag_list)
  end
  
  def test_parse_dates_parses_show_from_date_based_on_prefs
    params = { 'todo' => { 'show_from' => '5/20/07', 'due' => '5/23/07'}}
    prefs = flexmock()
    prefs.should_receive(:parse_date).with('5/20/07').and_return(Date.new(2007, 5, 20))
    prefs.should_receive(:parse_date).with('5/23/07').and_return(Date.new(2007, 5, 23))
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    params_helper.parse_dates()
    assert_equal Date.new(2007, 5, 20), params_helper.show_from
  end

  def test_parse_dates_parses_due_date_based_on_prefs
    params = { 'todo' => { 'show_from' => '5/20/07', 'due' => '5/23/07'}}
    prefs = flexmock()
    prefs.should_receive(:parse_date).with('5/20/07').and_return(Date.new(2007, 5, 20))
    prefs.should_receive(:parse_date).with('5/23/07').and_return(Date.new(2007, 5, 23))
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    params_helper.parse_dates()
    assert_equal Date.new(2007, 5, 23), params_helper.due
  end

  def test_parse_dates_sets_due_to_empty_string_if_nil
    params = { 'todo' => { 'show_from' => '5/20/07', 'due' => nil}}
    prefs = flexmock()
    prefs.should_receive(:parse_date).with('5/20/07').and_return(Date.new(2007, 5, 20))
    prefs.should_receive(:parse_date).with(nil).and_return(nil)
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    params_helper.parse_dates()
    assert_equal '', params_helper.due
  end
  
  def test_project_name_is_stripped_of_leading_and_trailing_whitespace
    params = { 'project_name' => ' Visit New Orleans  ' }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal 'Visit New Orleans', params_helper.project_name
  end
    
  def test_project_name_is_nil_when_unspecified
    params = { }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_nil params_helper.project_name
  end
    
  def test_context_name_is_stripped_of_leading_and_trailing_whitespace
    params = { 'context_name' => ' mobile phone  ' }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal 'mobile phone', params_helper.context_name
  end
  
  def test_context_name_is_nil_when_unspecified
    params = { }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_nil params_helper.context_name
  end
  
  def test_project_specified_by_name_is_false_when_project_id_is_specified
    params = { 'todo' => { 'project_id' => 2 } }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal false, params_helper.project_specified_by_name?
  end
  
  def test_project_specified_by_name_is_false_when_project_name_is_blank
    params = { 'project_name' => nil, 'todo' => {} }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal false, params_helper.project_specified_by_name?
  end
  
  def test_project_specified_by_name_is_false_when_project_name_is_none
    params = { 'project_name' => 'None', 'todo' => {} }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal false, params_helper.project_specified_by_name?
  end
  
  def test_context_specified_by_name_is_false_when_context_id_is_specified
    params = { 'todo' => { 'context_id' => 3 } }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal false, params_helper.context_specified_by_name?
  end
    
  def test_context_specified_by_name_is_false_when_context_name_is_blank
    params = { 'context_name' => nil, 'todo' => {} }
    prefs = flexmock()
    params_helper = TodosController::TodoCreateParamsHelper.new(params, prefs)
    assert_equal false, params_helper.context_specified_by_name?
  end
  
end