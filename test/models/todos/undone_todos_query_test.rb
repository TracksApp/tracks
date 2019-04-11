require 'test_helper'

module Todos
  class UndoneTodosQueryTest < ActiveSupport::TestCase
    def test_requires_a_user
      assert_raises(ArgumentError) { UndoneTodosQuery.new }
    end

    def test_default_query_is_all_active_not_hidden_todos
      user = users(:other_user)
      undone_todos = UndoneTodosQuery.new(user).query({})
      expected = [todos(:package_delivered),
                  todos(:buy_tix),
                  todos(:pal_confirmation)]
      assert_equal expected, undone_todos.to_a
    end

    def test_filtering_by_done
      user = users(:other_user)
      # This gets everything done from a week ago until now
      undone_todos = UndoneTodosQuery.new(user).query(done: '7')
      expected = [todos(:assemble_furniture)]
      assert_equal expected, undone_todos.to_a
    end

    def test_limiting_results
      user = users(:other_user)
      undone_todos = UndoneTodosQuery.new(user).query(limit: '1')
      expected = [todos(:package_delivered)]
      assert_equal expected, undone_todos.to_a
    end

    def test_filtering_by_due_date
      user = users(:other_user)
      # Only gets todos that are due today or are past their due date.
      undone_todos = UndoneTodosQuery.new(user).query(due: '0')
      expected = [todos(:package_delivered)]
      assert_equal expected, undone_todos.to_a
    end

    def test_filtering_by_tag
      user = users(:other_user)
      undone_todos = UndoneTodosQuery.new(user).query(tag: 'bar')
      expected = [todos(:package_delivered),
                  todos(:buy_tix)]
      assert_equal expected, undone_todos.to_a
    end

    def test_filtering_by_context
      user = users(:other_user)
      undone_todos = UndoneTodosQuery.new(user).query(context_id: '11')
      expected = [todos(:package_delivered),
                  todos(:pal_confirmation)]
      assert_equal expected, undone_todos.to_a
    end

    def test_using_a_non_existant_context_raises_an_exception
      user = users(:other_user)
      assert_raises(ActiveRecord::RecordNotFound) do
        undone_todos = UndoneTodosQuery.new(user).query(context_id: '110')
      end
    end

    def test_filtering_by_project
      user = users(:other_user)
      undone_todos = UndoneTodosQuery.new(user).query(project_id: '5')
      expected = [todos(:package_delivered)]
      assert_equal expected, undone_todos.to_a
    end

    def test_using_a_non_existant_project_raises_an_exception
      user = users(:other_user)
      assert_raises(ActiveRecord::RecordNotFound) do
        undone_todos = UndoneTodosQuery.new(user).query(project_id: '110')
      end
    end

    def test_combination_of_all_params
      user = users(:other_user)
      undone_todos = UndoneTodosQuery.new(user).query({
        limit: "1",
        project_id: "5",
        context_id: "11",
        tag: "bar",
        due: "0"})
      expected = [todos(:package_delivered)]
      assert_equal expected, undone_todos.to_a
    end
  end
end
