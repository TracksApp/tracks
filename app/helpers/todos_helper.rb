module TodosHelper

  def remote_star_icon(todo=@todo)
    link_to( image_tag_for_star(todo),
      toggle_star_todo_path(todo),
      :class => "icon star_item", :title => t('todos.star_action_with_description', :description => todo.description))
  end

  def remote_edit_button(todo=@todo)
    link_to(
      image_tag("blank.png", :alt => t('todos.edit'), :align => "absmiddle", :id => 'edit_icon_todo_'+todo.id.to_s, :class => 'edit_item'),
      {:controller => 'todos', :action => 'edit', :id => todo.id},
      :class => "icon edit_item",
      :id => "icon_edit_todo_#{todo.id}",
      :title => t('todos.edit_action_with_description', :description => todo.description))
  end

  def remote_delete_menu_item(todo)
    return link_to(
      t('todos.delete'),
      {:controller => 'todos', :action => 'destroy', :id => todo.id},
      :class => "icon_delete_item",
      :id => "delete_#{dom_id(todo)}",
      :x_confirm_message => t('todos.confirm_delete', :description => todo.description),
      :title => t('todos.delete_action'));
  end

  def remote_defer_menu_item(days, todo)
    url = {:controller => 'todos', :action => 'defer', :id => todo.id, :days => days,
      :_source_view => (@source_view.underscore.gsub(/\s+/,'_') rescue "")}
    url[:_tag_name] = @tag_name if @source_view == 'tag'

    options = {:x_defer_alert => false, :class => "icon_defer_item icon_defer_#{days}_item", :id => "defer_#{days}_#{dom_id(todo)}" }
    if todo.due
      futuredate = (todo.show_from || todo.user.date) + days.days
      if futuredate > todo.due
        options[:x_defer_alert] = true
        options[:x_defer_date_after_due_date] = t('todos.defer_date_after_due_date')
      end
    end

    return link_to(t('todos.defer_x_days', :count => days), url, options)
  end

  def remote_delete_dependency(todo, predecessor)
    link_to(
      image_tag("blank.png", :title => t('todos.remove_dependency'), :align => "absmiddle", :class => "delete_item"),
      url_for({:controller => 'todos', :action => 'remove_predecessor', :id => todo.id}),
      {:class => "delete_dependency_button", :x_predecessors_id => predecessor.id}
    )
  end

  def remote_promote_to_project_menu_item(todo)
    url = {:controller => 'todos', :action => 'convert_to_project', :id => todo.id,
      :_source_view => (@source_view.underscore.gsub(/\s+/,'_') rescue "")}
    url[:_tag_name] = @tag_name if @source_view == 'tag'

    return link_to(t('todos.convert_to_project'), url, {:class => "icon_item_to_project", :id => "to_project_#{dom_id(todo)}"})
  end

  def collapsed_notes_image(todo)
    link = link_to(
      image_tag( 'blank.png', :width=>'16', :height=>'16', :border=>'0' ),
      "#",
      {:class => 'show_notes', :title => 'Show notes'})
    notes = content_tag(:div, {
      :class => "todo_notes",
      :id => dom_id(todo, 'notes'),
      :style => "display:none"}) { raw todo.rendered_notes }
    return link+notes
  end

  def collapsed_successors_image(todo)
    link = link_to(image_tag( 'blank.png', :width=>'16', :height=>'16', :border=>'0' ), "#", {:class => 'show_successors', :title => 'Show successors'})
    successors = content_tag(:div, {:class => "todo_successors", :id => dom_id(todo, 'successors'), :style => "display:none"}) do
      render :partial => "todos/successor", :collection => todo.pending_successors,
        :locals => { :parent_container_type => parent_container_type, :suppress_dependencies => true, :predecessor => todo }
    end
    return link+successors
  end

  def image_tag_for_recurring_todo(todo)
    return link_to(
      image_tag("recurring16x16.png"),
      recurring_todos_path,
      :class => "recurring_icon", :title => recurrence_pattern_as_text(todo.recurring_todo))
  end

  def remote_toggle_checkbox(todo=@todo)
    check_box_tag("mark_complete_#{todo.id}", toggle_check_todo_path(todo), todo.completed?, :class => 'item-checkbox',
      :title => todo.pending? ? t('todos.blocked_by', :predecessors => todo.uncompleted_predecessors.map(&:description).join(', ')) : "", :readonly => todo.pending?)
  end

  def remote_mobile_checkbox(todo=@todo)
    form_tag toggle_check_todo_path(@todo, :format => 'm'), :method => :put, :class => "mobile-done", :name => "mobile_complete_#{@todo.id}" do
      check_box_tag('_source_view', 'todo', @todo && @todo.completed?, "onClick" => "document.mobile_complete_#{@todo.id}.submit()")
    end
  end

  def date_span(todo=@todo)
    if todo.completed?
      content_tag(:span, {:class => :grey}) { format_date( todo.completed_at ) }
    elsif todo.pending?
      title = t('todos.depends_on')+ ": " + todo.uncompleted_predecessors.map(&:description).join(', ')
      content_tag(:a, {:title => title}) { content_tag(:span, {:class => :orange}) { t('todos.pending') } }
    elsif todo.deferred?
      show_date( todo.show_from )
    else
      due_date( todo.due )
    end
  end

  def successors_span(todo=@todo)
    unless todo.pending_successors.empty?
      pending_count = todo.pending_successors.count
      title = "#{t('todos.has_x_pending', :count => pending_count)}: #{todo.pending_successors.map(&:description).join(', ')}"
      image_tag( 'successor_off.png', :width=>'10', :height=>'16', :border=>'0', :title => title )
    end
  end

  def grip_span(todo=@todo)
    unless todo.completed?
      image_tag('grip.png', :width => '7', :height => '16', :border => '0',
        :title => t('todos.drag_action_title'),
        :class => 'grip')
    end
  end

  def tag_list_text(todo=@todo)
    todo.tags.collect{|t| t.name}.join(', ')
  end

  def tag_span (tag, mobile=false)
    content_tag(:span, :class => "tag #{tag.name.gsub(' ','-')}") { link_to(tag.name, tag_path(tag.name, :format => mobile ? :m : nil)) }
  end

  def tag_list(todo=@todo, mobile=false)
    content_tag(:span, :class => 'tags') { todo.tags.all_except_starred.collect{|tag| tag_span(tag, mobile)}.join('').html_safe }
  end

  def tag_list_mobile(todo=@todo)
    todo.tags.all_except_starred.empty? ? "" : tag_list(todo, true)
  end

  def deferred_due_date(todo=@todo)
    t('todos.action_due_on', :date => format_date(todo.due)) if todo.deferred? && todo.due
  end

  def project_and_context_links(todo, parent_container_type, opts = {})
    str = ''
    if todo.completed?
      str += todo.context.name unless opts[:suppress_context]
      should_suppress_project = opts[:suppress_project] || todo.project.nil?
      str += ", " unless str.blank? || should_suppress_project
      str += todo.project.name unless should_suppress_project
      str = "(#{str})" unless str.blank?
    else
      if (['project', 'tag', 'stats', 'search'].include?(parent_container_type))
        str << item_link_to_context( todo )
      end
      if (['context', 'tickler', 'tag', 'stats', 'search'].include?(parent_container_type)) && !todo.project_id.nil? && !todo.project.is_a?(NullProject)
        str << item_link_to_project( todo )
      end
    end
    return str.html_safe
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

  def show_date_tag(date, the_class, text)
    content_tag(:a, :title => format_date(date)) do
      content_tag(:span, :class => the_class) { text }
    end
  end

  # Check show_from date in comparison to today's date Flag up date
  # appropriately with a 'traffic light' colour code
  #
  def show_date(d)
    return "" if d == nil

    days = days_from_today(d)

    case days
      # overdue or due very soon! sound the alarm!
    when -1000..-1
      show_date_tag(d, :red, t('todos.scheduled_overdue', :days => (days * -1).to_s))
    when 0
      show_date_tag(d, :amber, t('todos.show_today'))
    when 1
      show_date_tag(d, :amber, t('todos.show_tomorrow'))
      # due 2-7 days away
    when 2..7
      if prefs.due_style == Preference.due_styles[:due_on]
        show_date_tag(d, :orange, t('todos.show_on_date', :date => d.strftime("%A")) )
      else
        show_date_tag(d, :orange, t('todos.show_in_days', :days => days.to_s) )
      end
      # more than a week away - relax
    else
      show_date_tag(d, :green, t('todos.show_in_days', :days => days.to_s) )
    end
  end

  def should_show_new_item
    source_view do |page|
      page.todo { return !@todo.hidden? }
      page.deferred { return @todo.deferred? || @todo.pending? }
      page.context {
        return @todo.context_id==@default_context.id && ( (@todo.hidden? && @todo.context.hidden?) || (!@todo.hidden?) )
      }
      page.tag {
        return ( (@todo.pending? && @todo.has_tag?(@tag_name)) ||
            (@todo.has_tag?(@tag_name)) ||
            (@todo.starred? && @tag_name == Todo::STARRED_TAG_NAME)
        )
      }
      page.project {
        return (@todo.active? && @todo.project && @todo.project.id == @default_project.id) ||
          (@todo.project.hidden? && @todo.project_hidden?) ||
          ( @todo.deferred? && (@todo.project.id == @default_project.id) ) ||
          @todo.pending?
      }
    end

    return false
  end

  def should_make_context_visible
    return @todo.active? && (!@todo.hidden? && !source_view_is(:project) )
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
    projects = current_user.projects.uncompleted.includes(:default_context).where('NOT(default_context_id IS NULL)')
    Hash[*projects.map{ |p| [escape_javascript(p.name), escape_javascript(p.default_context.name)] }.flatten].to_json
  end

  def default_tags_for_autocomplete
    projects = current_user.projects.uncompleted.where("NOT(default_tags = '')")
    Hash[*projects.map{ |p| [escape_javascript(p.name), p.default_tags] }.flatten].to_json
  end

  def format_ical_notes(notes)
    unless notes.nil? || notes.blank?
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
    text_field_tag name, value, {"size" => 12, "id" => id, "class" => "Date", "autocomplete" => "off"}.update(options.stringify_keys)
  end

  def update_needs_to_hide_context
    return (@remaining_in_context == 0 && (@todo_hidden_state_changed && @todo.hidden?)) ||
      (@remaining_in_context == 0 && @todo_was_deferred_from_active_state) ||
      (@remaining_in_context == 0 && @tag_was_removed) ||
      (@remaining_in_context == 0 && @todo.completed? && !(@original_item_was_deferred || @original_item_was_hidden)) if source_view_is(:tag)

    return false if source_view_is_one_of(:project, :calendar)

    return (@remaining_in_context == 0) && !source_view_is(:context)
  end

  def update_needs_to_remove_todo_from_container
    source_view do |page|
      page.context  { return @context_changed || @todo_deferred_state_changed || @todo_pending_state_changed || @todo_should_be_hidden }
      page.project  { return @todo_deferred_state_changed || @todo_pending_state_changed || @project_changed}
      page.deferred { return @context_changed || !(@todo.deferred? || @todo.pending?) }
      page.calendar { return @due_date_changed || !@todo.due }
      page.stats    { return @todo.completed? }
      page.tag      { return (@context_changed && !@todo.hidden?) || @tag_was_removed || @todo_hidden_state_changed || @todo_deferred_state_changed }
      page.todo     { return @context_changed || @todo.hidden? || @todo.deferred? || @todo.pending?}
      page.search   { return false }
    end
    return false
  end

  def replace_with_updated_todo
    source_view do |page|
      page.context  { return !update_needs_to_remove_todo_from_container }
      page.project  { return !update_needs_to_remove_todo_from_container }
      page.deferred { return !@context_changed && (@todo.deferred? || @todo.pending?) }
      page.calendar { return !@due_date_changed && @todo.due }
      page.stats    { return !@todo.completed? }
      page.tag      { return !update_needs_to_remove_todo_from_container && !@tag_was_removed }
      page.todo     { return !update_needs_to_remove_todo_from_container }
      page.search   { return true }
    end
    return false
  end

  def append_updated_todo
    source_view do |page|
      page.context  { return @todo_deferred_state_changed || @todo_pending_state_changed }
      page.project  { return @todo_deferred_state_changed || @todo_pending_state_changed }
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
        return "tickler-empty-nd" if
          @todo_was_deferred_from_active_state ||
          @todo_was_blocked_from_active_state ||
          @todo_was_destroyed_from_deferred_state ||
          @todo_was_created_deferred ||
          @todo_was_blocked_from_completed_state ||
          @todo_was_created_blocked
        return "p#{todo.project_id}empty-nd"
      }
      page.tag {
        return "tickler-empty-nd" if
          @todo_was_deferred_from_active_state ||
          @todo_was_blocked_from_active_state ||
          @todo_was_destroyed_from_deferred_state ||
          @todo_was_created_deferred ||
          @todo_was_blocked_from_completed_state ||
          @todo_was_created_blocked
        return "hidden-empty-nd" if @todo.hidden?
        return "c#{todo.context_id}empty-nd"
      }
      page.calendar {
        return "tickler-empty-nd" if
          @todo_was_deferred_from_active_state ||
          @todo_was_blocked_from_active_state ||
          @todo_was_destroyed_from_deferred_state ||
          @todo_was_created_deferred ||
          @todo_was_blocked_from_completed_state ||
          @todo_was_created_blocked
        return "empty_#{@new_due_id}"
      }
      page.context {
        return "tickler-empty-nd" if
          @todo_was_deferred_from_active_state ||
          @todo_was_blocked_from_active_state ||
          @todo_was_destroyed_from_deferred_state ||
          @todo_was_created_deferred ||
          @todo_was_blocked_from_completed_state ||
          @todo_was_created_blocked
        return "c#{todo.context_id}empty-nd"
      }
    end

    return "c#{todo.context_id}empty-nd"
  end

  def todo_was_removed_from_deferred_or_blocked_container
    return @todo_was_activated_from_deferred_state ||
           @todo_was_activated_from_pending_state ||
           @todo_was_destroyed_from_deferred_or_pending_state ||
           @todo_was_completed_from_deferred_or_blocked_state
  end

  def show_empty_message_in_source_container
    container_id = ""
    source_view do |page|
      page.project  {
        container_id = "p#{@original_item_project_id}empty-nd" if @remaining_in_context == 0
        container_id = "tickler-empty-nd" if todo_was_removed_from_deferred_or_blocked_container && @remaining_deferred_or_pending_count == 0
        container_id = "empty-d" if @completed_count && @completed_count == 0 && !@todo.completed?
      }
      page.deferred { container_id = "c#{@original_item_context_id}empty-nd" if @remaining_in_context == 0 }
      page.calendar { container_id = "empty_#{@original_item_due_id}" if @old_due_empty }
      page.tag      {
        container_id = "hidden-empty-nd" if (@remaining_hidden_count == 0 && !@todo.hidden? && @todo_hidden_state_changed) ||
          (@remaining_hidden_count == 0 && @todo.completed? && @original_item_was_hidden)
        container_id = "tickler-empty-nd" if (todo_was_removed_from_deferred_or_blocked_container && @remaining_deferred_or_pending_count == 0) ||
          (@original_item_was_deferred && @remaining_deferred_or_pending_count == 0 && (@todo.completed? || @tag_was_removed))
        container_id = "empty-d" if @completed_count && @completed_count == 0 && !@todo.completed?
      }
      page.context  {
        container_id = "c#{@original_item_context_id}empty-nd" if @remaining_in_context == 0
        container_id = "tickler-empty-nd" if todo_was_removed_from_deferred_or_blocked_container && @remaining_deferred_or_pending_count == 0
        container_id = "empty-d" if @completed_count && @completed_count == 0 && !@todo.completed?
      }
      page.todo     { container_id = "c#{@original_item_context_id}empty-nd" if @remaining_in_context == 0 }
    end
    return container_id.blank? ? "" : "$(\"##{container_id}\").slideDown(100);".html_safe
  end

  def render_animation(animation)
    html = ""
    animation.each do |step|
      unless step.blank?
        html += step + "({ go: function() {\r\n"
      end
    end
    html += "}}) " * animation.size
    return html + ";"
  end

  def reset_tab_index
    $tracks_tab_index = 0
  end

  def next_tab_index
    # make sure it exists if reset was not called. Set to 20 to avoid clashes with existing form in sidebar
    $tracks_tab_index ||= 20

    $tracks_tab_index = $tracks_tab_index + 1
    return $tracks_tab_index
  end

  def feed_content_for_todo(todo)
    item_notes = todo.notes ? todo.rendered_notes : ''
    due = todo.due ? content_tag(:div, t('todos.feeds.due', :date => format_date(todo.due))) : ''
    done = todo.completed? ? content_tag(:div, t('todos.feeds.completed', :date => format_date(todo.completed_at))) : ''
    context_link = link_to(context_url(todo.context), todo.context.name)
    project_link = todo.project.is_a?(NullProject) ? content_tag(:em, t('common.none')) : link_to(project_url(todo.project), todo.project.name)
    return "#{done} #{due} #{item_notes}\n" +
      content_tag(:div, "#{t('common.project')}:  #{project_link}") + "\n" +
      content_tag(:div, "#{t('common.context')}:  #{context_link}")
  end
  
  private

  def image_tag_for_star(todo)
    image_tag("blank.png", :title =>t('todos.star_action'), :class => "todo_star"+(todo.starred? ? " starred":""), :id => "star_img_"+todo.id.to_s)
  end

end
