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
end
