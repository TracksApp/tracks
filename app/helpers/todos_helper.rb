module TodosHelper

  def remote_star_icon 
    link_to( image_tag_for_star(@todo),
      toggle_star_todo_path(@todo),
      :class => "icon star_item", :title => t('todos.star_action_with_description', :description => @todo.description))
  end

  def remote_edit_button
    link_to(
      image_tag("blank.png", :alt => t('todos.edit'), :align => "absmiddle", :id => 'edit_icon_todo_'+@todo.id.to_s, :class => 'edit_item'),
      {:controller => 'todos', :action => 'edit', :id => @todo.id},
      :class => "icon edit_item",
      :title => t('todos.edit_action_with_description', :description => @todo.description))
  end

  def remote_delete_menu_item(todo)
    return link_to(
      image_tag("delete_off.png", :mouseover => "delete_on.png", :alt => t('todos.delete'), :align => "absmiddle")+" "+t('todos.delete'),
      {:controller => 'todos', :action => 'destroy', :id => todo.id}, 
      :class => "icon_delete_item",
      :id => "delete_#{dom_id(todo)}",
      :title => t('todos.confirm_delete', :description => todo.description));
  end

  def remote_defer_menu_item(days, todo)
    url = {:controller => 'todos', :action => 'defer', :id => todo.id, :days => days,
      :_source_view => (@source_view.underscore.gsub(/\s+/,'_') rescue "")}
    url[:_tag_name] = @tag_name if @source_view == 'tag'

    futuredate = (@todo.show_from || @todo.user.date) + days.days
    options = {:x_defer_alert => false, :class => "icon_defer_item" }
    if @todo.due && futuredate > @todo.due
      options[:x_defer_alert] = true
      options[:x_defer_date_after_due_date] = t('todos.defer_date_after_due_date')
    end

    return link_to(image_tag_for_defer(days), url, options)
  end

  def remote_promote_to_project_menu_item(todo)
    url = {:controller => 'todos', :action => 'convert_to_project', :id => todo.id,
      :_source_view => (@source_view.underscore.gsub(/\s+/,'_') rescue "")}
    url[:_tag_name] = @tag_name if @source_view == 'tag'

    return link_to(image_tag("to_project_off.png", :align => "absmiddle")+" " + t('todos.convert_to_project'), url)
  end

  def image_tag_for_defer(days)
    image_tag("defer_#{days}_off.png", :mouseover => "defer_#{days}.png", :alt => t('todos.defer_x_days', :count => days), :align => "absmiddle")+" "+t('todos.defer_x_days', :count => days)
  end

  # waiting stuff can be deleted after migration of defer
  def todo_start_waiting_js(todo)
    return "$('#ul#{dom_id(todo)}').css('visibility', 'hidden'); $('##{dom_id(todo)}').block({message: null})"
  end

  def successor_start_waiting_js(successor)
    return "$('##{dom_id(successor, "successor")}').block({message: null})"
  end

  def todo_stop_waiting_js(todo)
    return "$('##{dom_id(todo)}').unblock();enable_rich_interaction();"
  end

  def image_tag_for_recurring_todo(todo)
    return link_to(
      image_tag("recurring16x16.png"),
      {:controller => "recurring_todos", :action => "index"},
      :class => "recurring_icon", :title => recurrence_pattern_as_text(todo.recurring_todo))
  end
  
  def remote_toggle_checkbox
    check_box_tag('item_id', toggle_check_todo_path(@todo), @todo.completed?, :class => 'item-checkbox',
      :title => @todo.pending? ? t('todos.blocked_by', :predecessors => @todo.uncompleted_predecessors.map(&:description).join(', ')) : "", :readonly => @todo.pending?)
  end
  
  def date_span
    if @todo.completed?
      "<span class=\"grey\">#{format_date( @todo.completed_at )}</span>"
    elsif @todo.pending?
      "<a title='#{t('todos.depends_on')}: #{@todo.uncompleted_predecessors.map(&:description).join(', ')}'><span class=\"orange\">#{t('todos.pending')}</span></a> "
    elsif @todo.deferred?
      show_date( @todo.show_from )
    else
      due_date( @todo.due )
    end
  end
  
  def successors_span
    unless @todo.pending_successors.empty?
      pending_count = @todo.pending_successors.length
      title = "#{t('todos.has_x_pending', :count => pending_count)}: #{@todo.pending_successors.map(&:description).join(', ')}"
      image_tag( 'successor_off.png', :width=>'10', :height=>'16', :border=>'0', :title => title )
    end
  end
  
  def grip_span
    unless @todo.completed?
      image_tag('grip.png', :width => '7', :height => '16', :border => '0', 
        :title => t('todos.drag_action_title'),
        :class => 'grip')
    end
  end
  
  def tag_list_text
    @todo.tags.collect{|t| t.name}.join(', ')
  end
  
  def tag_list
    tags_except_starred = @todo.tags.reject{|t| t.name == Todo::STARRED_TAG_NAME}
    tag_list = tags_except_starred.collect{|t| "<span class=\"tag #{t.name.gsub(' ','-')}\">" + link_to(t.name, :controller => "todos", :action => "tag", :id => t.name) + "</span>"}.join('')
    "<span class='tags'>#{tag_list}</span>"
  end
  
  def tag_list_mobile
    tags_except_starred = @todo.tags.reject{|t| t.name == Todo::STARRED_TAG_NAME}
    # removed the link. TODO: add link to mobile view of tagged actions
    tag_list = tags_except_starred.collect{|t| 
      "<span class=\"tag\">" + 
        link_to(t.name, {:action => "tag", :controller => "todos", :id => t.name+".m"}) + 
        "</span>"}.join('')
    if tag_list.empty? then "" else "<span class=\"tags\">#{tag_list}</span>" end
  end
  
  def predecessor_list_text
    @todo.predecessors.map{|t| t.specification}.join(', ')
  end

  def deferred_due_date
    if @todo.deferred? && @todo.due
      t('todos.action_due_on', :date => format_date(@todo.due))
    end
  end
  
  def project_and_context_links(parent_container_type, opts = {})
    str = ''
    if @todo.completed?
      str += @todo.context.name unless opts[:suppress_context]
      should_suppress_project = opts[:suppress_project] || @todo.project.nil?
      str += ", " unless str.blank? || should_suppress_project
      str += @todo.project.name unless should_suppress_project
      str = "(#{str})" unless str.blank?
    else
      if (['project', 'tag', 'stats', 'search'].include?(parent_container_type))
        str << item_link_to_context( @todo )
      end
      if (['context', 'tickler', 'tag', 'stats', 'search'].include?(parent_container_type)) && @todo.project_id
        str << item_link_to_project( @todo )
      end
    end
    return str
  end
    
  # Uses the 'staleness_starts' value from settings.yml (in days) to colour the
  # background of the action appropriately according to the age of the creation
  # date:
  # * l1: created more than 1 x staleness_starts, but < 2 x staleness_starts
  # * l2: created more than 2 x staleness_starts, but < 3 x staleness_starts
  # * l3: created more than 3 x staleness_starts
  #
  def staleness_class(item)
    if item.due || item.completed?
      return ""
    elsif item.created_at < current_user.time - (prefs.staleness_starts * 3).days
      return " stale_l3"
    elsif item.created_at < current_user.time - (prefs.staleness_starts * 2).days
      return " stale_l2"
    elsif item.created_at < current_user.time - (prefs.staleness_starts).days
      return " stale_l1"
    else
      return ""
    end
  end

  # Check show_from date in comparison to today's date Flag up date
  # appropriately with a 'traffic light' colour code
  #
  def show_date(d)
    if d == nil
      return ""
    end

    days = days_from_today(d)
       
    case days
      # overdue or due very soon! sound the alarm!
    when -1000..-1
      "<a title=\"" + format_date(d) + "\"><span class=\"red\">#{t('todos.scheduled_overdue', :days => (days * -1).to_s)}</span></a> "
    when 0
      "<a title=\"" + format_date(d) + "\"><span class=\"amber\">#{t('todos.show_today')}</span></a> "
    when 1
      "<a title=\"" + format_date(d) + "\"><span class=\"amber\">#{t('todos.show_tomorrow')}</span></a> "
      # due 2-7 days away
    when 2..7
      if prefs.due_style == Preference.due_styles[:due_on]
        "<a title=\"" + format_date(d) + "\"><span class=\"orange\">#{t('todos.show_on_date', :date => d.strftime("%A"))}</span></a> "
      else
        "<a title=\"" + format_date(d) + "\"><span class=\"orange\">#{t('todos.show_in_days', :days => days.to_s)}</span></a> "
      end
      # more than a week away - relax
    else
      "<a title=\"" + format_date(d) + "\"><span class=\"green\">#{t('todos.show_in_days', :days => days.to_s)}</span></a> "
    end
  end
  
  def should_show_new_item
    return false if source_view_is(:todo) && @todo.hidden?
    return false if source_view_is(:context) && @todo.hidden? && !@todo.context.hidden?

    return true if source_view_is(:tag) && (
      (@todo.pending? && @todo.tags.include?(@tag_name)) ||
        @todo.tags.include?(@tag_name) || 
        (@todo.starred? && @tag_name == Todo::STARRED_TAG_NAME))
    
    return false if (source_view_is(:context) && !(@todo.context_id==@default_context.id) )

    return true if source_view_is(:deferred) && @todo.deferred?
    return true if source_view_is(:project) && @todo.project.hidden? && @todo.project_hidden?
    return true if source_view_is(:project) && @todo.deferred?
    return true if source_view_is(:project) && @todo.pending?
    return true if !source_view_is(:deferred) && @todo.active?

    return false
  end

  def should_add_new_context
    return @new_context_created && !source_view_is(:project)
  end
  
  def parent_container_type
    return 'tickler' if source_view_is :deferred
    return 'project' if source_view_is :project
    return 'stats' if source_view_is :stats
    return 'tag' if source_view_is :tag
    return 'context'
  end
  
  def todo_container_is_empty
    default_container_empty = ( @down_count == 0 )
    deferred_container_empty = ( @todo.deferred? && @remaining_deferred_count == 0)
    return default_container_empty || deferred_container_empty
  end
  
  def default_contexts_for_autocomplete
    projects = current_user.projects.find(:all, :conditions => ['default_context_id is not null'])
    Hash[*projects.map{ |p| [p.name, p.default_context.name] }.flatten].to_json
  end
  
  def default_tags_for_autocomplete
    projects = current_user.projects.find(:all, :conditions => ["default_tags != ''"])
    Hash[*projects.map{ |p| [p.name, p.default_tags] }.flatten].to_json
  end

  def format_ical_notes(notes)
    unless notes.blank?
      split_notes = notes.split(/\n/)
      joined_notes = split_notes.join("\\n")
    end
    joined_notes || ""
  end
  
  def formatted_pagination(total)
    s = will_paginate(@todos)
    (s.gsub(/(<\/[^<]+>)/, '\1 ')).chomp(' ')
  end

  def date_field_tag(name, id, value = nil, options = {})
    text_field_tag name, value, {"size" => 12, "id" => id, "class" => "Date", "onfocus" => "Calendar.setup", "autocomplete" => "off"}.update(options.stringify_keys)
  end

  def update_needs_to_hide_context
    return (@remaining_in_context == 0 && (@todo_hidden_state_changed && @todo.hidden?)) ||
      (@remaining_in_context == 0 && @todo_was_deferred_from_active_state) if source_view_is(:tag)
    
    return (@remaining_in_context == 0) && !source_view_is(:context)
  end

  def update_needs_to_remove_todo_from_container
    source_view do |page|
      page.context  { return @context_changed || @todo.deferred? || @todo.pending? }
      page.project  { return @todo_deferred_state_changed }
      page.deferred { return @context_changed || !(@todo.deferred? || @todo.pending?) }
      page.calendar { return @due_date_changed || !@todo.due }
      page.stats    { return @todo.completed? }
      page.tag      { return (@context_changed && !@todo.hidden?) || @tag_was_removed || @todo_hidden_state_changed || @todo_deferred_state_changed }
      page.todo     { return @context_changed || @todo.hidden? || @todo.deferred? || @todo.pending?}
    end
    return false
  end

  def replace_with_updated_todo
    source_view do |page|
      page.context  { return !update_needs_to_remove_todo_from_container }
      page.project  { return !@todo_deferred_state_changed}
      page.deferred { return !@context_changed && (@todo.deferred? || @todo.pending?) }
      page.calendar { return !@due_date_changed && @todo.due }
      page.stats    { return !@todo.completed? }
      page.tag      { return !update_needs_to_remove_todo_from_container && !@tag_was_removed }
      page.todo     { return !update_needs_to_remove_todo_from_container }
    end
    return false
  end

  def append_updated_todo
    source_view do |page|
      page.context  { return false }
      page.project  { return @todo_deferred_state_changed }
      page.deferred { return @context_changed && (@todo.deferred? || @todo.pending?) }
      page.calendar { return @due_date_changed && @todo.due }
      page.stats    { return false }
      page.tag      { return update_needs_to_remove_todo_from_container && !@tag_was_removed}
      page.todo     { return @context_changed && !(@todo.deferred? || @todo.pending? || @todo.hidden?) }
    end
    return false
  end

  def item_container_id (todo)
    return "hiddenitems"              if source_view_is(:tag) && todo.hidden?
    return "c#{todo.context_id}items" if source_view_is :deferred
    return @new_due_id                if source_view_is :calendar
    return "tickleritems"             if !source_view_is(:todo) && (todo.deferred? || todo.pending?)
    return "completed_containeritems" if todo.completed?
    return "p#{todo.project_id}items" if source_view_is :project
    return "c#{todo.context_id}items"
  end

  def empty_container_msg_div_id(todo = @todo || @successor)
    raise Exception.new, "no @todo or @successor set" if !todo

    source_view do |page|
      page.project  {
        return "tickler-empty-nd" if @todo_was_deferred_from_active_state
        return "p#{todo.project_id}empty-nd"
      }
      page.tag {
        return "tickler-empty-nd" if @todo_was_deferred_from_active_state
        return "hidden-empty-nd" if @todo.hidden?
        return "c#{todo.context_id}empty-nd"
      }
      page.calendar {
        return "empty_#{@new_due_id}"
      }
    end

    return "c#{todo.context_id}empty-nd"
  end

  def show_empty_message_in_source_container
    container_id = ""
    source_view do |page|
      page.project  {
        container_id = "p#{@original_item_project_id}empty-nd" if @remaining_in_context == 0
        container_id = "tickler-empty-nd" if @todo_was_activated_from_deferred_state && @remaining_deferred_or_pending_count == 0
      }
      page.deferred { container_id = "c#{@original_item_context_id}empty-nd" if @remaining_in_context == 0 }
      page.calendar { container_id = "empty_#{@original_item_due_id}" if @old_due_empty }
      page.tag      {
        container_id = "hidden-empty-nd" if !@todo.hidden? && @todo_hidden_state_changed && @remaining_hidden_count == 0
        container_id = "tickler-empty-nd" if (@todo_was_activated_from_deferred_state && @remaining_deferred_or_pending_count == 0) ||
          (@original_item_was_deferred && @deferred_tag_count == 0 && @todo.completed?)
        container_id = "empty-d" if @completed_count && @completed_count == 0 && !@todo.completed?
      }
      page.context  { container_id = "c#{@original_item_context_id}empty-nd" if @remaining_in_context == 0 }
      page.todo     { container_id = "c#{@original_item_context_id}empty-nd" if @remaining_in_context == 0 }
    end
    return container_id.blank? ? "" : "$(\"##{container_id}\").slideDown(100);"
  end

  def render_animation(animation)
    html = ""
    animation.each do |step|
      unless step.blank?
        html += step + "({ go: function() {\r\n"
      end
    end
    html += "}}) " * animation.count
    return html
  end

  private
  
  def image_tag_for_star(todo)
    class_str = todo.starred? ? "starred_todo" : "unstarred_todo"
    image_tag("blank.png", :title =>t('todos.star_action'), :class => class_str, :id => "star_img_"+todo.id.to_s)
  end
  
  def auto_complete_result2(entries, phrase = nil)
    return entries.map{|e| e.specification()}.join("\n") rescue ''
  end

end
