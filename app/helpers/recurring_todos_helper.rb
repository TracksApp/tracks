module RecurringTodosHelper
  
  def recurrence_time_span(rt)
    case rt.ends_on
    when "no_end_date"
      return ""
    when "ends_on_number_of_times"
      return "for "+rt.number_of_occurences.to_s + " times"
    when "ends_on_end_date"
      starts = rt.start_from.nil? ? "" : "from " + format_date(rt.start_from)
      ends = rt.end_date.nil? ? "" : " until " + format_date(rt.end_date)
      return starts+ends
    else
      raise Exception.new, "unknown recurrence time span selection (#{self.ends_on})"    
    end
  end
  
  def recurrence_target(rt)
    case rt.target
    when 'due_date'
      return "due"
    when 'show_from_date'
      return "show"
    else
      return "ERROR"
    end
  end
    
  def recurring_todo_tag_list
    tags_except_starred = @recurring_todo.tags.reject{|t| t.name == Todo::STARRED_TAG_NAME}
    tag_list = tags_except_starred.collect{|t| "<span class=\"tag #{t.name.gsub(' ','-')}\">" + 
        # link_to(t.name, :controller => "todos", :action => "tag", :id =>
        # t.name) + TODO: tag view for recurring_todos (yet?)
      t.name + 
        "</span>"}.join('')
    "<span class='tags'>#{tag_list}</span>"
  end
 
  def recurring_todo_remote_delete_icon
    str = link_to( image_tag_for_delete,
      recurring_todo_path(@recurring_todo), :id => "delete_icon_"+@recurring_todo.id.to_s,
      :class => "icon delete_icon", :title => "delete the recurring action '#{@recurring_todo.description}'")
    set_behavior_for_delete_icon
    str
  end
  
  def recurring_todo_remote_star_icon 
    str = link_to( image_tag_for_star(@recurring_todo),
      toggle_star_recurring_todo_path(@recurring_todo),
      :class => "icon star_item", :title => "star the action '#{@recurring_todo.description}'")
    set_behavior_for_star_icon
    str
  end
  
  def recurring_todo_remote_edit_icon
    if !@recurring_todo.completed?
      str = link_to( image_tag_for_edit(@recurring_todo),
        edit_recurring_todo_path(@recurring_todo),
        :class => "icon edit_icon")
      set_behavior_for_edit_icon
    else
      str = '<a class="icon">' + image_tag("blank.png") + "</a> "
    end
    str
  end
  
  def recurring_todo_remote_toggle_checkbox
    str = check_box_tag('item_id', toggle_check_recurring_todo_path(@recurring_todo), @recurring_todo.completed?, :class => 'item-checkbox')
    set_behavior_for_toggle_checkbox
    str
  end
  
end