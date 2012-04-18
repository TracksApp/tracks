# The methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper
  
  # Replicates the link_to method but also checks request.request_uri to find
  # current page. If that matches the url, the link is marked id = "current"
  #
  def navigation_link(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to name, options, html_options
    # TODO: check if this needs to be converted
    # if html_options
    #   html_options = html_options.stringify_keys
    #   convert_options_to_javascript!(html_options)
    #   tag_options = tag_options(html_options)
    # else
    #   tag_options = nil
    # end
    # url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    # id_tag = (request.request_uri == url) ? " id=\"current\"" : ""
    #
    # "<a href=\"#{url}\"#{tag_options}#{id_tag}>#{name || url}</a>"
  end
  
  def days_from_today(date)
    Integer (date.in_time_zone.to_date - current_user.time.to_date)
  end
  
  # Check due date in comparison to today's date Flag up date appropriately with
  # a 'traffic light' colour code
  #
  def due_date(due)
    return "" if due.nil?

    days = days_from_today(due)

    colors = ['amber','amber','orange','orange','orange','orange','orange','orange']
    color = :red if days < 0
    color = :green if days > 7
    color = colors[days] if color.nil?
    
    return content_tag(:a, {:title => format_date(due)}) {
      content_tag(:span, {:class => color}) {
        case days
        when 0
          t('todos.next_actions_due_date.due_today')
        when 1
          t('todos.next_actions_due_date.due_tomorrow')
        when 2..7
          if prefs.due_style == Preference.due_styles[:due_on]
            # TODO: internationalize strftime here
            t('models.preference.due_on', :date => due.strftime("%A"))
          else
            t('models.preference.due_in', :days => days)
          end
        else
          # overdue or due very soon! sound the alarm!
          if days == -1
            t('todos.next_actions_due_date.overdue_by', :days => days * -1)
          elsif days < -1
            t('todos.next_actions_due_date.overdue_by_plural', :days => days * -1)
          else
            # more than a week away - relax
            t('models.preference.due_in', :days => days)
          end
        end
      }
    }
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
  def count_undone_todos_phrase(todos_parent)
    controller.count_undone_todos_phrase(todos_parent)
  end

  def count_undone_todos_phrase_text(todos_parent)
    count_undone_todos_phrase(todos_parent).gsub("&nbsp;"," ")
  end

  def count_undone_todos_and_notes_phrase(project)
    s = count_undone_todos_phrase(project)
    s += ", #{t('common.note', :count => project.note_count)}" unless project.note_count == 0
    s
  end
  
  def link_to_context(context, descriptor = sanitize(context.name))
    link_to( descriptor, context, :title => "View context: #{context.name}" )
  end
  
  def link_to_project(project, descriptor = sanitize(project.name))
    link_to( descriptor, project, :title => "View project: #{project.name}" )
  end

  def link_to_edit_note (note, descriptor = sanitize(note.id.to_s))
    link_to(descriptor,
      url_for({:controller => 'notes', :action => 'edit', :id => note.id}),
      {:id => "link_edit_#{dom_id(note)}", :class => "note_edit_settings"})
  end
  
  def link_to_project_mobile(project, accesskey, descriptor = sanitize(project.name))
    link_to( descriptor, project_path(project, :format => 'm'), {:title => "View project: #{project.name}", :accesskey => accesskey} )
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
    render :partial => 'shared/flash', :object => flash
  end

  def recurrence_time_span(rt)
    case rt.ends_on
    when "no_end_date"
      return rt.start_from.nil? ? "" : I18n.t("todos.recurrence.pattern.from") + " " + format_date(rt.start_from)
    when "ends_on_number_of_times"
      return I18n.t("todos.recurrence.pattern.times", :number => rt.number_of_occurences)
    when "ends_on_end_date"
      starts = rt.start_from.nil? ? "" : I18n.t("todos.recurrence.pattern.from") + " " + format_date(rt.start_from)
      ends = rt.end_date.nil? ? "" : " " + I18n.t("todos.recurrence.pattern.until") + " " + format_date(rt.end_date)
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

  def date_format_for_date_picker()
    standard_format = current_user.prefs.date_format
    translations = [
      ['%m', 'mm'],
      ['%b', 'M'],
      ['%B', 'MM'],
      ['%d', 'dd'],
      ['%a', 'D'],
      ['%A', 'DD'],
      ['%y', 'y'],
      ['%Y', 'yy']
    ]
    translations.inject(standard_format) do |str, translation|
      str.gsub(*translation)
    end
  end

  def sidebar_html_for_titled_list (list, title)
    return content_tag(:h3, title+" (#{list.length})")  + content_tag(:ul, sidebar_html_for_list(list))
  end

  def sidebar_html_for_list(list)
    if list.empty?
      return content_tag(:li, t('sidebar.list_empty')).html_safe
    else
      return list.inject("") do |html, item|
        link = (item.class == "Project") ? link_to_project( item ) : link_to_context(item)
        html << content_tag(:li, link + " (" + count_undone_todos_phrase(item)+")")
      end.html_safe
    end
  end

  def generate_i18n_strings
    js = "i18n_locale='#{I18n.locale}';\n"
    js << "i18n = new Array();\n"
    %w{
    shared.toggle_multi       shared.toggle_multi_title
    shared.hide_form          shared.hide_action_form_title
    shared.toggle_single      shared.toggle_single_title
    projects.hide_form        projects.hide_form_title
    projects.show_form        projects.show_form_title
    contexts.hide_form        contexts.hide_form_title
    contexts.show_form        contexts.show_form_title
    contexts.new_context_pre  contexts.new_context_post
    common.cancel             common.ok
    common.update             common.create
    common.ajaxError          todos.unresolved_dependency
    }.each do |s|
      js << "i18n['#{s}'] = '#{ t(s).gsub(/'/, "\\\\'") }';\n"
    end
    return js
  end

  def javascript_tag_for_i18n_datepicker
    locale = I18n.locale
    # do not include en as locale since this the available by default
    if locale and locale != :en
      javascript_include_tag("i18n/jquery.ui.datepicker-#{locale}.js")
    end
  end
  
  def determine_done_path
    case controller.controller_name
    when "contexts"
      done_todos_context_path(@context)
    when "projects"
      done_todos_project_path(@project)
    when "todos"
      if source_view_is(:tag)
        done_tag_path(@tag_name)
      else
        done_todos_path
      end
    else
      done_todos_path
    end
  end
  
  def determine_all_done_path
    case controller.controller_name
    when "contexts"
      all_done_todos_context_path(@context)
    when "projects"
      all_done_todos_project_path(@project)
    when "todos"
      if source_view_is(:tag)
        all_done_tag_path(@tag_name)
      else
        all_done_todos_path
      end
    else
      all_done_todos_path
    end
  end
  
  def get_list_of_error_messages_for(model)
    error_messages = ""
    if model.errors.any?
      list_of_messages = model.errors.full_messages.inject("") { |all, msg| all += content_tag(:li, msg) }
      error_messages = content_tag(:ul, list_of_messages)
    end
  end

end
