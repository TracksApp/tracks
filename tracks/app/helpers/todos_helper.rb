module TodosHelper

  require 'users_controller'
  # Counts the number of incomplete items in the specified context
  #
  def count_items(context)
    count = Todo.find_all("done=0 AND context_id=#{context.id}").length
  end

  def form_remote_tag_edit_todo( &block )
    form_tag( todo_path(@todo), {:method => :put, :id => dom_id(@todo, 'form'), :class => "edit_todo_form inline-form" }, &block )
    apply_behavior 'form.edit_todo_form', make_remote_form(:method => :put), :prevent_default => true
  end
  
  def remote_delete_icon
    str = link_to( image_tag_for_delete,
                   todo_path(@todo),
                   :class => "icon delete_icon", :title => "delete the action '#{@todo.description}'")
    apply_behavior '.item-container a.delete_icon:click', :prevent_default => true do |page|
       page << "if (confirm('Are you sure that you want to ' + this.title + '?')) {"
       page << "  new Ajax.Request(this.href, { asynchronous : true, evalScripts : true, method : 'delete', parameters : { '_source_view' : '#{@source_view}' }})"
       page << "}"
    end
    str
  end
  
  def remote_star_icon
    str = link_to( image_tag_for_star(@todo),
                   toggle_star_todo_path(@todo),
                   :class => "icon star_item", :title => "star the action '#{@todo.description}'")
    apply_behavior '.item-container a.star_item:click', 
      remote_function(:url => javascript_variable('this.href'), :method => 'put',
                      :with => "{ _source_view : '#{@source_view}' }"),
      :prevent_default => true
    str                   
  end
  
  def remote_edit_icon
    if !@todo.completed?
      str = link_to( image_tag_for_edit,
                      edit_todo_path(@todo),
                      :class => "icon edit_icon")
      apply_behavior '.item-container a.edit_icon:click', :prevent_default => true do |page|
        page << "new Ajax.Request(this.href, { asynchronous : true, evalScripts : true, method : 'get', parameters : { '_source_view' : '#{@source_view}' }, onLoading: function(request){ Effect.Pulsate(this)}});"
      end
    else
      str = '<a class="icon">' + image_tag("blank.png") + "</a> "
    end
    str
  end
  
  def remote_toggle_checkbox
    str = check_box_tag('item_id', toggle_check_todo_path(@todo), @todo.completed?, :class => 'item-checkbox')
    apply_behavior '.item-container input.item-checkbox:click',
                   remote_function(:url => javascript_variable('this.value'), :method => 'put',
                                   :with => "{ _source_view : '#{@source_view}' }")
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
    tag_list = @todo.tags.reject{|t| t.name == Todo::STARRED_TAG_NAME}.collect{|t| "<span class=\"tag\">" + link_to(t.name, :action => "tag", :id => t.name) + "</span>"}.join('')
    "<span class='tags'>#{tag_list}</span>"
  end
  
  def deferred_due_date
    if @todo.deferred? && @todo.due
      "(action due on #{format_date(@todo.due)})"
    end
  end
  
  def project_and_context_links(parent_container_type)
    if @todo.completed?
       "(#{@todo.context.name}#{", " + @todo.project.name unless @todo.project.nil?})"
    else
      str = ''
      if (['project', 'tag'].include?(parent_container_type))
        str << item_link_to_context( @todo )
      end
      if (['context', 'tickler', 'tag'].include?(parent_container_type)) && @todo.project_id
        str << item_link_to_project( @todo )
      end
      str
    end
  end
    
  # Uses the 'staleness_starts' value from settings.yml (in days) to colour
  # the background of the action appropriately according to the age
  # of the creation date:
  # * l1: created more than 1 x staleness_starts, but < 2 x staleness_starts
  # * l2: created more than 2 x staleness_starts, but < 3 x staleness_starts
  # * l3: created more than 3 x staleness_starts
  #
  def staleness_class(item)
    if item.due || item.completed?
      return ""
    elsif item.created_at < user_time - (prefs.staleness_starts * 3).days
      return " stale_l3"
    elsif item.created_at < user_time - (prefs.staleness_starts * 2).days
      return " stale_l2"
    elsif item.created_at < user_time - (prefs.staleness_starts).days
      return " stale_l1"
    else
      return ""
    end
  end

  # Check show_from date in comparison to today's date
  # Flag up date appropriately with a 'traffic light' colour code
  #
  def show_date(due)
    if due == nil
      return ""
    end

    days = days_from_today(due)
       
    case days
      # overdue or due very soon! sound the alarm!
      when -1000..-1
        "<a title='" + format_date(due) + "'><span class=\"red\">Shown on " + (days * -1).to_s + " days</span></a> "
      when 0
           "<a title='" + format_date(due) + "'><span class=\"amber\">Show Today</span></a> "
      when 1
           "<a title='" + format_date(due) + "'><span class=\"amber\">Show Tomorrow</span></a> "
      # due 2-7 days away
      when 2..7
      if prefs.due_style == Preference::DUE_ON_DUE_STYLE
        "<a title='" + format_date(due) + "'><span class=\"orange\">Show on " + due.strftime("%A") + "</span></a> "
      else
        "<a title='" + format_date(due) + "'><span class=\"orange\">Show in " + days.to_s + " days</span></a> "
      end
      # more than a week away - relax
      else
        "<a title='" + format_date(due) + "'><span class=\"green\">Show in " + days.to_s + " days</span></a> "
    end
  end
  
  def calendar_setup( input_field )
    str = "Calendar.setup({ ifFormat:\"#{prefs.date_format}\""
    str << ",firstDay:#{prefs.week_starts},showOthers:true,range:[2004, 2010]"
    str << ",step:1,inputField:\"" + input_field + "\",cache:true,align:\"TR\" })\n"
    javascript_tag str
  end
  
  def item_container_id
    if source_view_is :project
      return "p#{@todo.project_id}" if @todo.active?
      return "tickler" if @todo.deferred?
    end
    return "c#{@todo.context_id}"
  end

  def should_show_new_item
    return true if source_view_is(:deferred) && @todo.deferred?
    return true if source_view_is(:project) && @todo.project.hidden? && @todo.project_hidden?
    return true if source_view_is(:project) && @todo.deferred?
    return true if !source_view_is(:deferred) && @todo.active?
    return false
  end
  
  def parent_container_type
    return 'tickler' if source_view_is :deferred
    return 'project' if source_view_is :project
    return 'context'
  end
  
  def empty_container_msg_div_id
    return "tickler-empty-nd" if source_view_is(:project) && @todo.deferred?
    return "p#{@todo.project_id}empty-nd" if source_view_is :project
    return "c#{@todo.context_id}empty-nd"
  end
  
  def project_names_for_autocomplete
     array_or_string_for_javascript( ['None'] + @projects.select{ |p| p.active? }.collect{|p| escape_javascript(p.name) } )
  end
  
  def context_names_for_autocomplete
     #return array_or_string_for_javascript(['Create a new context']) if @contexts.empty?
     array_or_string_for_javascript( @contexts.collect{|c| escape_javascript(c.name) } )
  end

  def format_ical_notes(notes)
    split_notes = notes.split(/\n/)
    joined_notes = split_notes.join("\\n")
  end
  
  def formatted_pagination(total, per_page)
    s = will_paginate(@down_count, 6)
    (s.gsub /(<\/[^<]+>)/, '\1 ').chomp(' ')
  end

  def date_field_tag(name, id, value = nil, options = {})
    text_field_tag name, value, {"size" => 12, "id" => id, "class" => "Date", "onfocus" => "Calendar.setup", "autocomplete" => "off"}.update(options.stringify_keys)
  end
    
  private
  
  def image_tag_for_delete
    image_tag("blank.png", :title =>"Delete action", :class=>"delete_item")
  end
  
  def image_tag_for_edit
    image_tag("blank.png", :title =>"Edit action", :class=>"edit_item", :id=> dom_id(@todo, 'edit_icon'))
  end
  
  def image_tag_for_star(todo)
    class_str = todo.starred? ? "starred_todo" : "unstarred_todo"
    image_tag("blank.png", :title =>"Star action", :class => class_str)
  end  
  
end
