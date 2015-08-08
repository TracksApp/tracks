module ApplicationHelper

  def group_view_by_menu_entry
    # not set, no menu entry
    return "" if @group_view_by.nil?

    # if view == context, the menu shows Order By Project
    menu_name = @group_view_by == 'context' ? 'project' : 'context'

    content_tag(:li) do
      link_to(
        t("layouts.navigation.group_view_by_#{menu_name}"),
        '#',
        {:id => "group_view_by_link", :accesskey => "g", :title => t('layouts.navigation.group_view_by_title'), :x_current_group_by => @group_view_by} )
    end
  end

  def container_toggle(id)
    link_to(
      image_tag("blank.png", :alt => t('common.collapse_expand')),
      "#",
      {:class => "container_toggle", :id => id} )
  end

  def navigation_link(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to name, options, html_options
  end

  # Check due date in comparison to today's date Flag up date appropriately with
  # a 'traffic light' colour code
  #
  def due_date(due)
    return DateLabelHelper::DueDateView.new(due, prefs).due_date_html
  end

  # Check due date in comparison to today's date Flag up date appropriately with
  # a 'traffic light' colour code Modified method for mobile screen
  #
  def due_date_mobile(due)
    return DateLabelHelper::DueDateView.new(due, prefs).due_date_mobile_html
  end

  # Returns a count of next actions in the given context or project. The result
  # is count and a string descriptor, correctly pluralised if there are no
  # actions or multiple actions
  #
  def count_undone_todos_phrase(todos_parent)
    controller.count_undone_todos_phrase(todos_parent).html_safe
  end

  def count_undone_todos_phrase_text(todos_parent)
    count_undone_todos_phrase(todos_parent).gsub("&nbsp;"," ").html_safe
  end

  def count_undone_todos_and_notes_phrase(project)
    s = count_undone_todos_phrase(project)
    s += ", #{t('common.note', :count => project.note_count)}" unless project.note_count == 0
    s.html_safe
  end

  def link_to_context(context, descriptor = sanitize(context.name))
    link_to( descriptor, context, :title => "View context: #{context.name}" )
  end

  def link_to_project(project, descriptor = sanitize(project.name))
    link_to( descriptor, project, :title => "View project: #{project.name}" )
  end

  def link_to_edit_note (note, descriptor = sanitize(note.id.to_s))
    link_to(descriptor, edit_note_path(note),
      {:id => "link_edit_#{dom_id(note)}", :class => "note_edit_settings"})
  end

  def link_to_project_mobile(project, accesskey, descriptor = sanitize(project.name))
    link_to( descriptor, project_path(project, :format => 'm'), {:title => "View project: #{project.name}", :accesskey => accesskey} )
  end

  def item_link_to_context(item)
    link_to_context( item.context, prefs.verbose_action_descriptors ? "[#{item.context.name}]" : "[C]" )
  end

  def item_link_to_project(item)
    link_to_project( item.project, prefs.verbose_action_descriptors ? "[#{item.project.name}]" : "[P]" )
  end

  def render_flash
    render :partial => 'shared/flash', :object => flash
  end

  def time_span_text(date, i18n_text)
    return (date ? "#{i18n_text} #{format_date(date)}" : "").html_safe
  end

  def recurrence_time_span(rt)
    case rt.ends_on
    when "no_end_date"
      return time_span_text(rt.start_from, I18n.t("todos.recurrence.pattern.from"))
    when "ends_on_number_of_times"
      return I18n.t("todos.recurrence.pattern.times", :number => rt.number_of_occurrences)
    when "ends_on_end_date"
      starts = time_span_text(rt.start_from, I18n.t("todos.recurrence.pattern.from"))
      ends = time_span_text(rt.end_date, I18n.t("todos.recurrence.pattern.until"))
      return starts+ends
    else
      raise Exception.new, "unknown recurrence time span selection (#{rt.ends_on})"
    end
  end

  def recurrence_pattern_as_text(recurring_todo)
    recurring_target = recurring_todo.recurring_target_as_text

    recurrence_pattern = recurring_todo.recurrence_pattern
    recurrence_pattern = ' ' + recurrence_pattern unless recurrence_pattern.nil?

    recurrence_time_span = recurrence_time_span(recurring_todo)
    recurrence_time_span = ' ' + recurrence_time_span unless recurrence_time_span.empty?

    recurring_target + recurrence_pattern + recurrence_time_span
  end

  def date_format_for_date_picker()
    [
      ['%m', 'mm'],
      ['%b', 'M'],
      ['%B', 'MM'],
      ['%d', 'dd'],
      ['%a', 'D'],
      ['%A', 'DD'],
      ['%y', 'y'],
      ['%Y', 'yy']
    ].inject(current_user.prefs.date_format) { |str, translation| str.gsub(*translation) }
  end

  def sidebar_html_for_titled_list (list, title)
    return content_tag(:h3, title+" (#{list.size})")  + content_tag(:ul, sidebar_html_for_list(list))
  end

  def link_to_sidebar_item(item)
    item.is_a?(Project) ? link_to_project( item ) : link_to_context( item )
  end

  def sidebar_html_for_item(item)
    content_tag(:li, link_to_sidebar_item(item) + " (" + count_undone_todos_phrase(item)+")")
  end

  def sidebar_html_for_list(list)
    return content_tag(:li, t('sidebar.list_empty')).html_safe if list.empty?
    return list.inject("") { |html, item| html << sidebar_html_for_item(item) }.html_safe
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
    return js.html_safe
  end

  def javascript_tag_for_i18n_datepicker
    locale = I18n.locale
    # do not include en as locale since this the available by default
    if locale && locale != :en
      javascript_include_tag("i18n/jquery.ui.datepicker-#{locale}.js")
    end
  end

  def done_path(controller_name, type)
    case controller_name
    when "contexts"
      send("#{type}_todos_context_path",@context)
    when "projects"
      send("#{type}_todos_project_path", @project)
    when "todos"
      if @tag_name
        send("#{type}_tag_path",@tag_name)
      else
        send("#{type}_todos_path")
      end
    else
      send("#{type}_todos_path")
    end
  end

  def determine_done_path
    done_path(controller.controller_name, :done)
  end

  def determine_all_done_path
    done_path(controller.controller_name, :all_done)
  end

  def get_list_of_error_messages_for(model)
    if model.errors.any?
      content_tag(:div, {:id=>"errorExplanation"}) do
        content_tag(:ul) do
          model.errors.full_messages.collect { |msg| concat(content_tag(:li, msg)) }
        end
      end
    end
  end

  def link_to_delete(type, object, descriptor = sanitize(object.name))
    link_to(
      descriptor,
      self.send("#{type}_path", object, :format => 'js'),
      {
        :id => "delete_#{type}_#{object.id}",
        :class => "delete_#{type}_button icon",
        :x_confirm_message => t("#{type}s.delete_#{type}_confirmation", :name => object.name),
        :title => t("#{type}s.delete_#{type}_title")
      }
    )
  end

  def link_to_edit(type, object, descriptor)
    link_to(descriptor, self.send("edit_#{type}_path", object),
      {
        :id => "link_edit_#{dom_id(object)}",
        :class => "#{type}_edit_settings icon"
      })
  end

  def source_view_key
    # uses @project.id or @context.id depending on source_view
    source_view_is_one_of(:project, :context) ? "#{@source_view}-#{eval("@#{@source_view}.id")}" : @source_view
  end

  # create a unique object name which can be used in ajax calls returning js
  # to prevent concurrent calls with same functions to overwrite each other functions
  def unique_object_name_for(name)
    "#{name}_#{SecureRandom.hex(5)}"
  end

  def js_render(partial, locals = {}, object=nil)
    if object
      escape_javascript(render(partial: partial, locals: locals, object: object))
    else
      escape_javascript(render(partial: partial, locals: locals))
    end
  end

  def js_error_messages_for(object)
    escape_javascript(get_list_of_error_messages_for(object))
  end

end
