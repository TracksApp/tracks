require "test_helper"

class TodosHelpersTest < ActionView::TestCase
  include TodosHelper

  test "remote_edit_button" do
    html = remote_edit_button(todos(:call_bill))
    assert_equal "<a class=\"icon edit_item\" href=\"/todos/1/edit\" id=\"icon_edit_todo_1\" title=\"Edit the action &#39;Call Bill Gates to find out how much he makes per day&#39;\"><img align=\"absmiddle\" alt=\"Edit\" class=\"edit_item\" id=\"edit_icon_todo_1\" src=\"/images/blank.png\" /></a>", html
  end

  test "remote_delete_menu" do
    html = remote_delete_menu_item(todos(:call_bill))
    assert_equal "<a class=\"icon_delete_item\" href=\"/todos/1\" id=\"delete_todo_1\" title=\"Delete action\" x_confirm_message=\"Are you sure that you want to delete the action &#39;Call Bill Gates to find out how much he makes per day&#39;?\">Delete</a>", html
  end

  test "remote_delete_dependency" do
    todo = todos(:call_bill_gates_every_day)
    predecessor = todos(:call_bill)
    html = remote_delete_dependency(todo, predecessor)
    assert_equal "<a class=\"delete_dependency_button\" href=\"/todos/18/remove_predecessor\" x_predecessors_id=\"1\"><img align=\"absmiddle\" alt=\"Blank\" class=\"delete_item\" src=\"/images/blank.png\" title=\"Remove dependency (does not delete the action)\" /></a>", html
  end

  test "remote_promote_to_project_menu_item" do
    html = remote_promote_to_project_menu_item(todos(:call_bill))
    assert_equal "<a class=\"icon_item_to_project\" href=\"/todos/1/convert_to_project?_source_view=\" id=\"to_project_todo_1\">Make project</a>", html
  end
end
