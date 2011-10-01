require File.dirname(__FILE__) + '/../test_helper'
require 'todos_controller'

# Re-raise errors caught by the controller.
class TodosController; def rescue_action(e) raise e end; end

class TodosControllerTest < ActionController::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :tags, :taggings, :recurring_todos

  def test_get_boolean_expression_from_parameters_of_tag_view_single_tag
    login_as(:admin_user)
    get :tag, :name => "single"
    assert_equal true, assigns['single_tag'], "should recognize it is a single tag name"
    assert_equal "single", assigns['tag_expr'][0][0], "should store the single tag"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_tags
    login_as(:admin_user)
    get :tag, :name => "multiple", :and => "tags", :and1 => "present", :and2 => "here"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 4, assigns['tag_expr'].size, "should have 4 AND expressions"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_tags_without_digitless_and
    login_as(:admin_user)
    get :tag, :name => "multiple", :and1 => "tags", :and2 => "present", :and3 => "here"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 4, assigns['tag_expr'].size, "should have 4 AND expressions"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_ORs
    login_as(:admin_user)
    get :tag, :name => "multiple,tags,present"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 1, assigns['tag_expr'].size, "should have 1 expressions"
    assert_equal 3, assigns['tag_expr'][0].size, "should have 3 ORs in 1st expression"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_ORs_and_ANDS
    login_as(:admin_user)
    get :tag, :name => "multiple,tags,present", :and => "here,is,two", :and1=>"and,three"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 3, assigns['tag_expr'].size, "should have 3 expressions"
    assert_equal 3, assigns['tag_expr'][0].size, "should have 3 ORs in 1st expression"
    assert_equal 3, assigns['tag_expr'][1].size, "should have 3 ORs in 2nd expression"
    assert_equal 2, assigns['tag_expr'][2].size, "should have 2 ORs in 3rd expression"
  end

  def test_get_ids_from_tag_expr
    login_as(:admin_user)

    # make sure the tags exits
    # "multiple,tags,present,here,is,two,and,three".split(',').each { |tag| Tag.find_or_create_by_name(:name=>tag)}

    get :tag, :name => "foo,bar", :and => "baz"

    assert_equal 1, assigns['tag_ids'][0][0], "first id should be 1 for foo"
    assert_equal 2, assigns['tag_ids'][0][1], "second id should be 2 for bar"
    assert_equal 3, assigns['tag_ids'][1][0], "third id should be 3 for baz"
  end

end