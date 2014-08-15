module RecurringTodosHelper

  def recurring_todo_tag_list
    tags_except_starred = @recurring_todo.tags.reject{|t| t.name == Todo::STARRED_TAG_NAME}
    tag_list = tags_except_starred.
      collect{|t| content_tag(:span,link_to(t.name, tag_path(t.name)), :class => "tag #{t.label}")}.
      join('')
    return content_tag :span, tag_list.html_safe, :class => "tags"
  end

  def recurring_todo_remote_delete_icon
    link_to( image_tag_for_delete,
      recurring_todo_path(@recurring_todo), :id => "delete_icon_"+@recurring_todo.id.to_s,
      :class => "icon delete_icon", :title => t('todos.delete_recurring_action_title'), :x_confirm_message => t('todos.delete_recurring_action_confirm', :description => @recurring_todo.description))
  end

  def recurring_todo_remote_star_icon
    link_to( image_tag_for_star(@recurring_todo),
      toggle_star_recurring_todo_path(@recurring_todo), :id => "star_icon_"+@recurring_todo.id.to_s,
      :class => "icon star_item", :title => t('todos.star_action'))
  end

  def recurring_todo_remote_edit_icon
    if !@recurring_todo.completed?
      str = link_to( image_tag_for_edit(@recurring_todo),
        edit_recurring_todo_path(@recurring_todo),
        :class => "icon edit_icon", :id => "link_edit_recurring_todo_#{@recurring_todo.id}")
    else
      str = content_tag(:a, image_tag("blank.png"), :class => "icon")
    end
    str
  end

  def recurring_todo_remote_toggle_checkbox
    return check_box_tag("check_#{@recurring_todo.id}", toggle_check_recurring_todo_path(@recurring_todo), @recurring_todo.completed?, :class => 'item-checkbox')
  end

  private

  def image_tag_for_delete
    image_tag("blank.png", :title =>t('todos.delete_action'), :class=>"delete_item")
  end

  def image_tag_for_edit(todo)
    image_tag("blank.png", :title =>t('todos.edit_action'), :class=>"edit_item", :id=> dom_id(todo, 'edit_icon'))
  end
end
