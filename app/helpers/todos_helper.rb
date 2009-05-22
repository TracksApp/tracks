module TodosHelper

  # #require 'users_controller' Counts the number of incomplete items in the
  # specified context
  #
  def count_items(context)
    count = Todo.find_all("done=0 AND context_id=#{context.id}").length
  end

  def form_remote_tag_edit_todo( &block )
    form_tag( 
      todo_path(@todo), {
        :method => :put, 
        :id => dom_id(@todo, 'form'), 
        :class => dom_id(@todo, 'form') + " inline-form edit_todo_form" }, 
      &block )
    apply_behavior 'form.edit_todo_form', make_remote_form(
      :method => :put, 
      :before => "todoSpinner = this.down('button.positive'); todoSpinner.startWaiting()",
      :loaded => "todoSpinner.stopWaiting()",
      :condition => "!(this.down('button.positive').isWaiting())"),
      :prevent_default => true
  end
  
  def set_behavior_for_star_icon
    apply_behavior '.item-container a.star_item:click', 
      remote_to_href(:method => 'put', :with => "{ _source_view : '#{@source_view}' }"),
      :prevent_default => true
  end    

  def remote_star_icon 
    str = link_to( image_tag_for_star(@todo),
      toggle_star_todo_path(@todo),
      :class => "icon star_item", :title => "star the action '#{@todo.description}'")
    set_behavior_for_star_icon
    str
  end

  def remote_edit_menu_item(parameters, todo)
    return link_to_remote(
      image_tag("edit_off.png", :mouseover => "edit_on.png", :alt => "", :align => "absmiddle")+" Edit",
      :url => {:controller => 'todos', :action => 'edit', :id => todo.id},
      :method => 'get',
      :with => "'#{parameters}'",
      :before => todo_start_waiting_js(todo),
      :complete => todo_stop_waiting_js)
  end

  def remote_delete_menu_item(parameters, todo)
    return link_to_remote(
      image_tag("delete_off.png", :mouseover => "delete_on.png", :alt => "", :align => "absmiddle")+" Delete",
      :url => {:controller => 'todos', :action => 'destroy', :id => todo.id},
      :method => 'delete',
      :with => "'#{parameters}'",
      :before => todo_start_waiting_js(todo),
      :complete => todo_stop_waiting_js)
  end

  def remote_defer_menu_item(days, todo)
    url = {:controller => 'todos', :action => 'defer', :id => todo.id, :days => days,
      :_source_view => (@source_view.underscore.gsub(/\s+/,'_') rescue "")}
    url[:_tag_name] = @tag_name if @source_view == 'tag'
    
    futuredate = (@todo.show_from || @todo.user.date) + days.days
    if @todo.due && futuredate > @todo.due
      return link_to_function(
        image_tag("defer_#{days}_off.png", :mouseover => "defer_#{days}.png", :alt => "", :align => "absmiddle")+" Defer #{pluralize(days, "day")}",
        "alert('Defer date is after due date. Please edit and adjust due date before deferring.')"
      )
    else
      return link_to_remote(
        image_tag("defer_#{days}_off.png", :mouseover => "defer_#{days}.png", :alt => "", :align => "absmiddle")+" Defer #{pluralize(days, "day")}",
        :url => url,
        :before => todo_start_waiting_js(todo),
        :complete => todo_stop_waiting_js)
    end
  end

  def todo_start_waiting_js(todo)
    return "$('ul#{dom_id(todo)}').hide(); itemContainer = $('#{dom_id(todo)}'); itemContainer.startWaiting()"
  end

  def todo_stop_waiting_js
    return "itemContainer.stopWaiting();"
  end

  def image_tag_for_recurring_todo(todo)
    return link_to(
      image_tag("recurring16x16.png"),
      {:controller => "recurring_todos", :action => "index"},
      :class => "recurring_icon", :title => recurrence_pattern_as_text(todo.recurring_todo))
  end

  def set_behavior_for_toggle_checkbox
    parameters = "_source_view=#{@source_view}"
    parameters += "&_tag_name=#{@tag_name}" if @source_view == 'tag'
    apply_behavior '.item-container input.item-checkbox:click',
      remote_function(:url => javascript_variable('this.value'), :method => 'put',
      :with => "'#{parameters}'")    
  end
  
  def remote_toggle_checkbox
    str = check_box_tag('item_id', toggle_check_todo_path(@todo), @todo.completed?, :class => 'item-checkbox')
    set_behavior_for_toggle_checkbox
    str
  end
  
  def date_span
    if @todo.completed?
      "<span class=\"grey\">#{format_date( @todo.completed_at )}</span>"
    elsif @todo.deferred?
      show_date( @todo.show_from )
    else
      due_date( @todo.due )
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
  
  def deferred_due_date
    if @todo.deferred? && @todo.due
      "(action due on #{format_date(@todo.due)})"
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
      "<a title=\"" + format_date(d) + "\"><span class=\"red\">Scheduled to show " + (days * -1).to_s + " days ago</span></a> "
    when 0
      "<a title=\"" + format_date(d) + "\"><span class=\"amber\">Show Today</span></a> "
    when 1
      "<a title=\"" + format_date(d) + "\"><span class=\"amber\">Show Tomorrow</span></a> "
      # due 2-7 days away
    when 2..7
      if prefs.due_style == Preference.due_styles[:due_on]
        "<a title=\"" + format_date(d) + "\"><span class=\"orange\">Show on " + d.strftime("%A") + "</span></a> "
      else
        "<a title=\"" + format_date(d) + "\"><span class=\"orange\">Show in " + days.to_s + " days</span></a> "
      end
      # more than a week away - relax
    else
      "<a title=\"" + format_date(d) + "\"><span class=\"green\">Show in " + days.to_s + " days</span></a> "
    end
  end
  
  def calendar_setup( input_field )
    str = "Calendar.setup({ ifFormat:\"#{prefs.date_format}\""
    str << ",firstDay:#{prefs.week_starts},showOthers:true,range:[2004, 2010]"
    str << ",step:1,inputField:\"" + input_field + "\",cache:true,align:\"TR\" })\n"
    javascript_tag str
  end
  
  def item_container_id (todo)
    if source_view_is :project
      return "p#{todo.project_id}items" if todo.active?
      return "tickler" if todo.deferred?
    end
    return "c#{todo.context_id}"
  end

  def should_show_new_item

    if @todo.project.nil? == false
      # do not show new actions that were added to hidden or completed projects
      # on home page and context page
      return false if source_view_is(:todo) && (@todo.project.hidden? || @todo.project.completed?)
      return false if source_view_is(:context) && (@todo.project.hidden? || @todo.project.completed?)      
    end

    return true if source_view_is(:deferred) && @todo.deferred?
    return true if source_view_is(:project) && @todo.project.hidden? && @todo.project_hidden?
    return true if source_view_is(:project) && @todo.deferred?
    return true if !source_view_is(:deferred) && @todo.active?
    return false
  end
  
  def parent_container_type
    return 'tickler' if source_view_is :deferred
    return 'project' if source_view_is :project
    return 'stats' if source_view_is :stats
    return 'context'
  end
  
  def empty_container_msg_div_id
    return "tickler-empty-nd" if source_view_is_one_of(:project, :tag) && @todo.deferred?
    return "p#{@todo.project_id}empty-nd" if source_view_is :project
    return "c#{@todo.context_id}empty-nd"
  end
  
  def project_names_for_autocomplete
    array_or_string_for_javascript( ['None'] + current_user.projects.active.collect{|p| escape_javascript(p.name) } )
  end
  
  def context_names_for_autocomplete
    # #return array_or_string_for_javascript(['Create a new context']) if
    # @contexts.empty?
    array_or_string_for_javascript( current_user.contexts.collect{|c| escape_javascript(c.name) } )
  end

  def format_ical_notes(notes)
    split_notes = notes.split(/\n/)
    joined_notes = split_notes.join("\\n")
  end
  
  def formatted_pagination(total)
    s = will_paginate(@todos)
    (s.gsub(/(<\/[^<]+>)/, '\1 ')).chomp(' ')
  end

  def date_field_tag(name, id, value = nil, options = {})
    text_field_tag name, value, {"size" => 12, "id" => id, "class" => "Date", "onfocus" => "Calendar.setup", "autocomplete" => "off"}.update(options.stringify_keys)
  end
    
  private
  
  def image_tag_for_star(todo)
    class_str = todo.starred? ? "starred_todo" : "unstarred_todo"
    image_tag("blank.png", :title =>"Star action", :class => class_str)
  end
end
