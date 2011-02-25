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
    link_to( descriptor, context, :title => "View context: #{context.name}" )
  end
  
  def link_to_project(project, descriptor = sanitize(project.name))
    link_to( descriptor, project, :title => "View project: #{project.name}" )
  end

  def link_to_edit_project (project, descriptor = sanitize(project.name))
    link_to(descriptor,
      url_for({:controller => 'projects', :action => 'edit', :id => project.id}),
      {:id => "link_edit_#{dom_id(project)}", :class => "project_edit_settings"})
  end

  def link_to_edit_context (context, descriptor = sanitize(context.name))
    link_to(descriptor,
      url_for({:controller => 'contexts', :action => 'edit', :id => context.id}),
      {:id => "link_edit_#{dom_id(context)}", :class => "context_edit_settings"})
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

  AUTO_LINK_MESSAGE_RE = %r{message://<[^>]+>} unless const_defined?(:AUTO_LINK_MESSAGE_RE)

  # Converts message:// links to href. This URL scheme is used on Mac OS X
  # to link to a mail message in Mail.app.
  def auto_link_message(text)
    text.gsub(AUTO_LINK_MESSAGE_RE) do
      href = $&
      left, right = $`, $'
      # detect already linked URLs and URLs in the middle of a tag
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is alreay linked
        href
      else
        content = content_tag(:a, h(href), :href => h(href))
      end
    end
  end

  def format_note(note)
    note = auto_link_message(note)
    note = markdown(note)
    note = auto_link(note, :link => :urls)

    # add onenote and message protocols
    Sanitize::Config::RELAXED[:protocols]['a']['href'] << 'onenote'
    Sanitize::Config::RELAXED[:protocols]['a']['href'] << 'message'

    note = Sanitize.clean(note, Sanitize::Config::RELAXED)
    return note
  end

  def sidebar_html_for_titled_list (list, title)
    return content_tag(:h3, title+" (#{list.length})") +
      content_tag(:ul, sidebar_html_for_list(list))
  end

  def sidebar_html_for_list(list)
    if list.empty?
      return content_tag(:li, t('sidebar.list_empty'))
    else
      return list.inject("") do |html, item|
        link = (item.class == "Project") ? link_to_project( item ) : link_to_context(item)
        html << content_tag(:li, link + " (" + count_undone_todos_phrase(item,"actions")+")")
      end
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
    common.ajaxError
    }.each do |s|
      js << "i18n['#{s}'] = '#{ t(s).gsub(/'/, "\\\\'") }';\n"
    end
    return js
  end

  def javascript_tag_for_i18n_datepicker
    # do not include en as locale since this the available by default
    locales_without_en = I18n::available_locales.find_all{|locale| !(locale.to_s == 'en') }
    return javascript_include_tag(locales_without_en.map{|locale| "i18n/jquery.ui.datepicker-#{locale}.js"})
  end

end
