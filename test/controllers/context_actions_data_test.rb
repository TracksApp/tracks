require 'test_helper'

class ContextActionsDataTest < ActionController::TestCase
  tests StatsController

  def test_total_with_more_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_total_actions_data

    assert_equal [47, 17, 34], assigns[:data].values
  end

  def test_running_actions
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_running_actions_data

    assert_equal [47, 17, 34], assigns[:data].values
  end

end
