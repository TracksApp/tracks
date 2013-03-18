require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContextActionsDataTest < ActionController::TestCase
  tests StatsController

  def test_total_with_0_items
    login_as(:admin_user)
    Stats::TopContextsQuery.any_instance.stubs(:result).returns []

    get :context_total_actions_data

    assert_equal [], assigns[:actions_per_context]
  end

  def test_total_with_less_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_total_actions_data

    assert_equal contexts, assigns[:actions_per_context]
  end

  def test_total_with_exactly_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_total_actions_data

    assert_equal contexts, assigns[:actions_per_context]
  end

  def test_total_with_more_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19},
      {'id' => 11, 'name' => 'eleven', 'total' => 14}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_total_actions_data

    contexts.pop
    contexts[-1] = {'id' => -1, 'name' => '(others)', 'total' => 33}
    assert_equal contexts, assigns[:actions_per_context]
  end

  def test_running_with_0_items
    login_as(:admin_user)
    Stats::TopContextsQuery.any_instance.stubs(:result).returns []

    get :context_running_actions_data

    assert_equal [], assigns[:actions_per_context]
  end

  def test_running_with_less_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_running_actions_data

    assert_equal contexts, assigns[:actions_per_context]
  end

  def test_running_with_exactly_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_running_actions_data

    assert_equal contexts, assigns[:actions_per_context]
  end

  def test_running_with_more_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19},
      {'id' => 11, 'name' => 'eleven', 'total' => 14}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_running_actions_data

    contexts.pop
    contexts[-1] = {'id' => -1, 'name' => '(others)', 'total' => 33}
    assert_equal contexts, assigns[:actions_per_context]
  end

end
