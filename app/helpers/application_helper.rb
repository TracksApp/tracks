# The methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper
  
  # Replicates the link_to method but also checks request.request_uri to find
  # current page. If that matches the url, the link is marked id = "current"
  #
  def navigation_link(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)    
    id_tag = (request.request_uri == url) ? " id=\"current\"" : ""
    
    "<a href=\"#{url}\"#{tag_options}#{id_tag}>#{name || url}</a>"
  end
  
  def days_from_today(date)
    date.in_time_zone.to_date - current_user.time.to_date
  end
  
  # Check due date in comparison to today's date Flag up date appropriately with
  # a 'traffic light' colour code
  #
  def due_date(due)
    if due == nil
      return ""
    end

    days = days_from_today(due)
       
    case days
    when 0
      "<a title='#{format_date(due)}'><span class=\"amber\">Due Today</span></a> "
    when 1
      "<a title='#{format_date(due)}'><span class=\"amber\">Due Tomorrow</span></a> "
      # due 2-7 days away
    when 2..7
      if prefs.due_style == Preference.due_styles[:due_on]
        "<a title='#{format_date(due)}'><span class=\"orange\">Due on #{due.strftime("%A")}</span></a> "
      else
        "<a title='#{format_date(due)}'><span class=\"orange\">Due in #{pluralize(days, 'day')}</span></a> "
      end
    else
      # overdue or due very soon! sound the alarm!
      if days < 0
        "<a title='#{format_date(due)}'><span class=\"red\">Overdue by #{pluralize(days * -1, 'day')}</span></a> "
      else
        # more than a week away - relax
        "<a title='#{format_date(due)}'><span class=\"green\">Due in #{pluralize(days, 'day')}</span></a> "
      end
    end
  end

  # Check due date in comparison to today's date Flag up date appropriately with
  # a 'traffic light' colour code Modified method for mobile screen
  #
  def due_date_mobile(due)
    if due == nil
      return ""
    end

    days = days_from_today(due)
       
    case days
    when 0
      "<span class=\"amber\">"+ format_date(due) + "</span>"
    when 1
      "<span class=\"amber\">" + format_date(due) + "</span>"
      # due 2-7 days away
    when 2..7
      "<span class=\"orange\">" + format_date(due) + "</span>"
    else
      # overdue or due very soon! sound the alarm!
      if days < 0
        "<span class=\"red\">" + format_date(due) +"</span>"
      else
        # more than a week away - relax
        "<span class=\"green\">" + format_date(due) + "</span>"
      end
    end
  end
  
  # Returns a count of next actions in the given context or project. The result
  # is count and a string descriptor, correctly pluralised if there are no
  # actions or multiple actions
  #
  def count_undone_todos_phrase(todos_parent, string="actions")
    @controller.count_undone_todos_phrase(todos_parent, string)
  end

  def count_undone_todos_phrase_text(todos_parent, string="actions")
    count_undone_todos_phrase(todos_parent, string).gsub("&nbsp;"," ")
  end

  def count_undone_todos_and_notes_phrase(project, string="actions")
    s = count_undone_todos_phrase(project, string)
    s += ", #{pluralize(project.note_count, 'note')}" unless project.note_count == 0
    s
  end
  
  def link_to_context(context, descriptor = sanitize(context.name))
    link_to( descriptor, context_path(context), :title => "View context: #{context.name}" )
  end
  
  def link_to_project(project, descriptor = sanitize(project.name))
    link_to( descriptor, project_path(project), :title => "View project: #{project.name}" )
  end
  
  def link_to_project_mobile(project, accesskey, descriptor = sanitize(project.name))
    link_to( descriptor, formatted_project_path(project, :m), {:title => "View project: #{project.name}", :accesskey => accesskey} )
  end
  
  def item_link_to_context(item)
    descriptor = "[C]"
    descriptor = "[#{item.context.name}]" if prefs.verbose_action_descriptors
    link_to_context( item.context, descriptor )
  end
  
  def item_link_to_project(item)
    descriptor = "[P]"
    descriptor = "[#{item.project.name}]" if prefs.verbose_action_descriptors
    link_to_project( item.project, descriptor )
  end
  
  def render_flash
    render :partial => 'shared/flash', :locals => { :flash => flash }
  end
  
  # Display a flash message in RJS templates Usage: page.notify :warning, "This
  # is the message", 5.0 Puts the message into a flash of type 'warning', fades
  # over 5 secs
  def notify(type, message, fade_duration)
    type = type.to_s  # symbol to string
    page.replace 'flash', "<h4 id='flash' class='alert #{type}'>#{message}</h4>" 
    page.visual_effect :fade, 'flash', :duration => fade_duration
  end

  def recurrence_time_span(rt)
    case rt.ends_on
    when "no_end_date"
      return rt.start_from.nil? ? "" : "from " + format_date(rt.start_from)
    when "ends_on_number_of_times"
      return "for "+rt.number_of_occurences.to_s + " times"
    when "ends_on_end_date"
      starts = rt.start_from.nil? ? "" : "from " + format_date(rt.start_from)
      ends = rt.end_date.nil? ? "" : " until " + format_date(rt.end_date)
      return starts+ends
    else
      raise Exception.new, "unknown recurrence time span selection (#{rt.ends_on})"
    end
  end

  def recurrence_pattern_as_text(recurring_todo)
    rt = recurring_todo.recurring_target_as_text
    rp = recurring_todo.recurrence_pattern
    # only add space if recurrence_pattern has content
    rp = " " + rp if !rp.nil?
    rts = recurrence_time_span(recurring_todo)
    # only add space if recurrence_time_span has content
    rts = " " + rts if !(rts == "")
    return rt+rp+rts
  end

end
