module TodosHelper

  # === helpers for rendering container

  def empty_message_holder(container_name, show, title_param=nil)
    content_tag(:div, :id => "no_todos_in_view", :class => "container #{container_name}", :style => "display:" + (show ? "block" : "none") ) do
      content_tag(:h2) { t("todos.no_actions.title", :param=>title_param) } +
      content_tag(:div, :class => "message") do
        content_tag(:p) { t("todos.no_actions.#{container_name}", :param=>title_param) }
      end
    end
  end

  def todos_container_empty_message(container_name, container_id, show_message)
    content_tag(:div, :id=>"#{container_id}-empty-d", :style=>"display:#{show_message ? 'block' : 'none'}") do
      content_tag(:div, :class=>"message") do
        content_tag(:p) do
          t("todos.no_actions.#{container_name}")
        end
      end
    end
  end

  def show_grouped_todos(settings = {})
    collection = (@group_view_by == 'context') ? @contexts_to_show : @projects_to_show
    render(:partial => collection, :locals => { :settings => settings.reverse_merge!({
      :collapsible => true,
      :show_empty_containers => @show_empty_containers,
      :parent_container_type => @group_view_by
    })})
  end

  def default_collection_settings
    {
      :suppress_context => false,
      :suppress_project => false,
      :collapsible => false,
      :append_descriptor => nil,
      :parent_container_type => nil,
      :show_empty_containers => true
    }
  end

  def show_done_todos(done_todos, settings={})
    settings[:container_name] = "completed"
    settings[:link_in_header] = link_to(t('common.show_all'), determine_done_path)

    render :partial => 'todos/collection',
      :object => done_todos,
      :locals => {:settings => settings.reverse_merge!(default_collection_settings)}
  end

  def show_completed_todos_for(period, collection)
    settings = {
      :parent_container_type => "completed",
      :container_name => "completed_#{period}",
      :title => t("todos.completed_#{period}"),
      :show_empty_containers => true
    }

    render :partial => "todos/collection",
      :object => collection,
      :locals => { :settings => settings}
  end

  def show_hidden_todos(hidden_todos, settings={})
    settings[:container_name] = "hidden"

    render :partial => 'todos/collection',
      :object => hidden_todos,
      :locals => {:settings => settings.reverse_merge!(default_collection_settings)}
  end

  def show_deferred_pending_todos(deferred_todos, pending_todos, settings={})
    settings[:pending] = pending_todos
    settings[:container_name]="deferred_pending"

    render :partial => "todos/collection",
      :object => deferred_todos+pending_todos,
      :locals => {:settings => settings.reverse_merge!(default_collection_settings)}
  end

  def show_todos_without_project(todos_without_project, settings = {})
    render :partial => 'todos/collection',
      :object => todos_without_project,
      :locals => {:settings => settings.reverse_merge!({
        :collapsible => true,
        :container_name => "without_project",
        :parent_container_type => "home"
        })
      }
  end

  def todos_container(settings={})
    settings.reverse_merge!({
      :id => "#{settings[:container_name]}_container",
      :class => "container #{settings[:container_name]}",
      })

    if settings[:collapsible]
      settings[:class] += " collapsible"
    end

    content_tag(:div,
      :class=>settings[:class],
      :id=>settings[:id],
      :style => "display:" + (settings[:show_container] ? "block" : "none")) do
      yield
    end
  end

  def todos_container_header(settings={})
    settings.reverse_merge!({
        :title => t("todos.actions.#{settings[:parent_container_type]}_#{settings[:container_name]}", :param => settings[:title_param])
      })
    header = settings[:link_in_header].nil? ? "" : content_tag(:div, :class=>"link_in_container_header"){settings[:link_in_header]}
    header += content_tag(:h2) do
      toggle = settings[:collapsible] ? container_toggle("toggle_#{settings[:id]}") : ""
      "#{toggle} #{settings[:title]} #{settings[:append_descriptor]}".html_safe
    end
    header.html_safe
  end

  def todos_container_items(collection, settings={})
    settings.reverse_merge!({:id => "#{settings[:container_name]}"})
    # do not pass :class to partial locals
    settings.delete(:class)

    content_tag(:div, :id =>settings[:id]+"_items", :class=>"items toggle_target") do
      todos_container_empty_message(settings[:container_name], settings[:id], collection.empty?) +
      render(:partial => "todos/todo", :collection => collection, :locals => settings)
    end
  end

  def todos_calendar_container(period, collection)
    render :partial => 'todos/collection',
      :object => collection,
      :locals => {:settings => {
        :collapsible => false,
        :show_empty_containers => true,
        :container_name => "#{period}",
        :title =>t("todos.calendar.#{period}", :month => l(Time.zone.now, :format => "%B"), :next_month => l(1.month.from_now, :format => "%B"))
        }
      }
  end

  # === helpers for rendering a todo

  def remote_star_icon(todo=@todo)
    link_to( image_tag_for_star(todo),
      toggle_star_todo_path(todo),
      :class => "icon star_item", :title => t('todos.star_action_with_description', :description => todo.description))
  end

  def remote_edit_button(todo=@todo)
    link_to(
      image_tag("blank.png", :alt => t('todos.edit'), :align => "absmiddle", :id => dom_id(todo, "edit_icon"), :class => 'edit_item'),
      edit_todo_path(todo),
      :class => "icon edit_item",
      :id => dom_id(todo, "icon_edit"),
      :title => t('todos.edit_action_with_description', :description => todo.description))
  end

  def remote_delete_menu_item(todo)
    return link_to(
      t('todos.delete'),
      {:controller => 'todos', :action => 'destroy', :id => todo.id},
      :class => "icon_delete_item",
      :id => dom_id(todo, "delete"),
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
      if futuredate.at_midnight > todo.due.at_midnight
        options[:x_defer_alert] = true
        options[:x_defer_date_after_due_date] = t('todos.defer_date_after_due_date')
      end
    end

    return link_to(t('todos.defer_x_days', :count => days), url, options)
  end

  def remote_delete_dependency(todo, predecessor)
    link_to(
      image_tag("blank.png", :title => t('todos.remove_dependency'), :align => "absmiddle", :class => "delete_item"),
      remove_predecessor_todo_path(todo),
      {:class => "delete_dependency_button", :x_predecessors_id => predecessor.id}
    )
  end

  def remote_promote_to_project_menu_item(todo)
    url = {:controller => 'todos', :action => 'convert_to_project', :id => todo.id,
      :_source_view => (@source_view.underscore.gsub(/\s+/,'_') rescue "")}
    url[:_tag_name] = @tag_name if @source_view == 'tag'

    link_to(t('todos.convert_to_project'), url, {:class => "icon_item_to_project", :id => dom_id(todo, "to_project")})
  end

  def attachment_image(todo)
    link_to(
      image_tag('blank.png', width: 16, height: 16, border:0),
      todo.attachments.first.file.url,
      {:class => 'todo_attachment', title: 'Get attachments of this todo'}
    )
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

  def image_tag_for_star(todo)
    image_tag("blank.png", :title =>t('todos.star_action'), :class => "todo_star"+(todo.starred? ? " starred":""), :id => "star_img_"+todo.id.to_s)
  end

  def remote_toggle_checkbox(todo=@todo)
    check_box_tag("mark_complete_#{todo.id}", toggle_check_todo_path(todo), todo.completed?, :class => 'item-checkbox',
      :title => todo.pending? ? t('todos.blocked_by', :predecessors => todo.uncompleted_predecessors.to_a.map(&:description).join(', ')) : "", :readonly => todo.pending?)
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
      title = t('todos.depends_on')+ ": " + todo.uncompleted_predecessors.to_a.map(&:description).join(', ')
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
      title = "#{t('todos.has_x_pending', :count => pending_count)}: #{todo.pending_successors.to_a.map(&:description).join(', ')}"
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
    todo.tags.to_a.join(', ')
  end

  def tag_span (tag, mobile=false)
    content_tag(:span, :class => "tag #{tag.label}") { link_to(tag.name, tag_path(tag.name, :format => mobile ? :m : nil)) }
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
    links = ''
    if todo.completed?
      links << item_link_to_context( todo ) unless opts[:suppress_context]
      links << item_link_to_project( todo ) unless opts[:suppress_project] || todo.project.nil?
    else
      links << item_link_to_context( todo ) if include_context_link(todo, parent_container_type)
      links << item_link_to_project( todo ) if include_project_link(todo, parent_container_type)
    end

    links.html_safe
  end

  def include_context_link(todo, parent_container_type)
    return true if (['stats', 'search'].include?(parent_container_type))
    # TODO: remove next line if 'project' supports group_view_by
    return true if parent_container_type == 'project'
    return true if @group_view_by == 'project'
    return false
  end

  def include_project_link(todo, parent_container_type)
    return false unless todo.has_project?
    return true if (['stats', 'search'].include?(parent_container_type))
    # TODO: remove next line if 'context' supports group_view_by
    return true if parent_container_type == 'context'
    return true if @group_view_by == 'context'
    return false
  end

  # Uses the 'staleness_starts' value from settings.yml (in days) to colour the
  # background of the action appropriately according to the age of the creation
  # date:
  # * l1: created more than 1 x staleness_starts, but < 2 x staleness_starts
  # * l2: created more than 2 x staleness_starts, but < 3 x staleness_starts
  # * l3: created more than 3 x staleness_starts
  #
  def staleness_class(item)
    days_stale = Staleness.days_stale(item, current_user)
    start = current_user.prefs.staleness_starts
    case days_stale
    when 0...start
      ""
    when start...start*2
      " stale_l1"
    when start*2...start*3
      " stale_l2"
    else
      " stale_l3"
    end
  end

  def show_date(date)
    return DateLabelHelper::ShowFromDateView.new(date, prefs).show_from_date_html
  end

  def date_field_tag(name, id, value = nil, options = {})
    text_field_tag name, value, {"size" => 12, "id" => id, "class" => "Date", "autocomplete" => "off"}.update(options.stringify_keys)
  end

  def sort_key(todo)
    # actions are sorted using {order("todos.due IS NULL, todos.due ASC, todos.created_at ASC")}
    # the JavaScript frontend sorts using unicode/ascii
    format = "%Y%m%d%H%M%S%L"
    if todo.due?
      sort_by_due = todo.due.strftime format
    else
      sort_by_due = "Z" * 17 # length of format string
    end
    sort_by_due + todo.created_at.strftime(format)
  end

  # === helpers for default layout

  def default_contexts_for_autocomplete
    projects = current_user.projects.uncompleted.includes(:default_context).where('NOT(default_context_id IS NULL)')
    Hash[*projects.map{ |p| [escape_javascript(p.name), escape_javascript(p.default_context.name)] }.flatten].to_json
  end

  def default_tags_for_autocomplete
    projects = current_user.projects.uncompleted.where("NOT(default_tags = '')")
    Hash[*projects.map{ |p| [escape_javascript(p.name), p.default_tags] }.flatten].to_json
  end

  # === various helpers

  def formatted_pagination(total)
    s = will_paginate(@todos)
    (s.gsub(/(<\/[^<]+>)/, '\1 ')).chomp(' ')
  end

  def format_ical_notes(notes)
    if notes.present?
      split_notes = notes.split(/\n/)
      joined_notes = split_notes.join("\\n")
    end
    joined_notes || ""
  end

  def parent_container_type
    return 'tickler' if source_view_is :deferred
    return 'project' if source_view_is :project
    return 'stats'   if source_view_is :stats
    return 'tag'     if source_view_is :tag
    return 'context'
  end

  # jquery animations are async, so first collect all animation steps that need
  # to be run sequential in array animation, then execute them. All steps are
  # functions which are passed a function as parameter that should execute the next
  # animation steps.
  # if the animation needs to be run inside the namespace of an object, set the
  # object_name to the name of the object and this name will be prepended to each step
  def render_animation(animation, object_name=nil)
    object_name += "." unless object_name.nil?  # add dot if object_name is given

    # concatenate all steps into functions that call functions
    html = animation.map{ |step| "#{object_name}#{step}({ go: function() {" }.join("\r\n")
    # close all functions
    html += "}}) " * animation.size + ";"

    return html
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

  # === handle CRUD actions for todos

  def show_todo_on_current_context_page
    return @todo.context_id==@default_context.id
  end

  def todo_should_not_be_hidden_on_context_page
    return !@todo.hidden? ||                        # todo is not hidden --> show
           (@todo.hidden? && @todo.context.hidden?) # todo is hidden, but context is hidden too --> show
  end

  def show_todo_on_current_project_page
    return @todo.project.id == @default_project.id
  end

  def todo_should_not_be_hidden_on_project_page
    return !@todo.hidden? ||
           (@todo.project_hidden? && @todo.project.hidden?)
  end

  def should_show_new_item(todo = @todo)
    return false if todo.nil?
    source_view do |page|
      page.todo     { return !todo.hidden? && !todo.deferred? }
      page.deferred { return todo.deferred? || todo.pending? }
      page.context  { return show_todo_on_current_context_page && todo_should_not_be_hidden_on_context_page }
      page.tag      { return todo.has_tag?(@tag_name) }
      page.project  { return show_todo_on_current_project_page && todo_should_not_be_hidden_on_project_page }
    end
    return false
  end

  def should_make_context_visible
    return @todo.active? && (!@todo.hidden? && !source_view_is(:project) )
  end

  def should_add_new_container
    if @group_view_by == 'project'
      return @new_project_created && !source_view_is(:context)
    else
      return @new_context_created && !source_view_is(:project)
    end
  end

  def todo_container_is_empty
    default_container_empty = ( @down_count == 0 )
    deferred_container_empty = ( @todo.deferred? && @remaining_deferred_count == 0)
    return default_container_empty || deferred_container_empty
  end

  def todo_moved_out_of_container
    # moved from one project container to another
    moved_project = @project_changed && @group_view_by=='project'
    # moved from one context container to another
    moved_context = @context_changed && @group_view_by=='context'
    # moved from actions-without-project container to another
    moved_without_project = @context_changed && @group_view_by=='project' && @todo.project_id.nil?

    return moved_project || moved_context || moved_without_project
  end

  def update_needs_to_hide_container
    if source_view_is_one_of(:tag, :context, :project)
      return @remaining_in_context == 0 && (
        todo_moved_out_of_container                                                       ||
        (@todo_hidden_state_changed && @todo.hidden?)                                     ||
        @todo_was_deferred_from_active_state                                              ||
        @tag_was_removed                                                                  ||
        @todo_was_destroyed                                                               ||
        (@todo.completed? && !(@original_item_was_deferred || @original_item_was_hidden || @original_item_was_pending))
      )
    end

    return false if source_view_is_one_of(:calendar, :done, :all_done)

    return @remaining_in_context == 0
  end

  def update_needs_to_remove_todo_from_container
    source_view do |page|
      page.context  { return @context_changed || @todo_deferred_state_changed || @todo_pending_state_changed || @todo_should_be_hidden }
      page.project  { return @context_changed || @todo_deferred_state_changed || @todo_pending_state_changed || @project_changed}
      page.deferred { return todo_moved_out_of_container || !(@todo.deferred? || @todo.pending?) }
      page.calendar { return @due_date_changed || !@todo.due }
      page.stats    { return @todo.completed? }
      page.tag      { return ( (@context_changed | @project_changed) && !@todo.hidden?) || @tag_was_removed || @todo_hidden_state_changed || @todo_deferred_state_changed }
      page.todo     { return todo_moved_out_of_container || @todo.hidden? || @todo.deferred? || @todo.pending?}
      page.search   { return false }
    end
    return false
  end

  def update_needs_to_add_new_container
    needs_new_context = @new_context_created && (@group_view_by == "context")
    needs_new_project = @new_project_created && (@group_view_by == "project")
    return needs_new_project || needs_new_context
  end

  def replace_with_updated_todo
    source_view do |page|
      page.context  { return !update_needs_to_remove_todo_from_container }
      page.project  { return !update_needs_to_remove_todo_from_container }
      page.deferred { return !todo_moved_out_of_container && (@todo.deferred? || @todo.pending?) }
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
      page.project  { return @context_changed || @todo_deferred_state_changed || @todo_pending_state_changed }
      page.deferred { return todo_moved_out_of_container && (@todo.deferred? || @todo.pending?) }
      page.calendar { return @due_date_changed && @todo.due }
      page.stats    { return false }
      page.tag      { return update_needs_to_remove_todo_from_container && !@tag_was_removed}
      page.todo     { return todo_moved_out_of_container && !(@todo.deferred? || @todo.pending? || @todo.hidden?) }
    end
    return false
  end

  def should_show_empty_container
    source_view do |page|
      page.context { return @remaining_in_context == 0 }
    end
    return @down_count==0
  end

  def project_container_id(todo)
    return "p#{todo.project_id}"         unless todo.project.nil?
    return "without_project_container"
  end

  def context_container_id(todo)
    return "c#{todo.context_id}"
  end

  def todo_container_id(todo)
    return project_container_id(todo) if @group_view_by == "project"
    return context_container_id(todo)
  end

  def project_container_empty_id(todo)
    return "p#{todo.project_id}-empty-d" unless todo.project.nil?
    return "without_project_container-empty-d"
  end

  def context_container_empty_id(todo)
    return "c#{todo.context_id}-empty-d"
  end

  def todo_container_empty_id(todo)
    raise Exception.new, "no todo set in TodosHelper::todo_container_empty_id. You probably did not assign @original_item" if !todo
    @group_view_by == "project" ? project_container_empty_id(todo) : context_container_empty_id(todo)
  end

  def item_container_id (todo)
    return "hidden_container"           if source_view_is(:tag) && todo.hidden?
    return todo_container_id(todo)      if source_view_is :deferred
    return "#{@new_due_id}_container"   if source_view_is :calendar
    return "deferred_pending_container" if !source_view_is(:todo) && (todo.deferred? || todo.pending?)
    return "completed_container"        if todo.completed?
    return project_container_id(todo)   if source_view_is_one_of(:todo, :tag, :project, :context) && @group_view_by == 'project'
    return context_container_id(todo)
  end

  def empty_container_msg_div_id(todo = @todo || @successor)
    raise Exception.new, "no @todo or @successor set" if !todo

    source_view do |page|
      page.project  {
        return "deferred_pending_container-empty-d" if empty_criteria_met
        return todo_container_empty_id(todo)
      }
      page.tag {
        return "deferred_pending_container-empty-d" if empty_criteria_met
        return "hidden_container-empty-d"           if @todo.hidden?
        return todo_container_empty_id(todo)
      }
      page.calendar {
        return "deferred_pending_container-empty-d" if empty_criteria_met
        return "#{@new_due_id}_container-empty-d"
      }
      page.context {
        return "deferred_pending_container-empty-d" if empty_criteria_met
        return todo_container_empty_id(todo)
      }
      page.todo {
        return todo_container_empty_id(todo)
      }
      page.deferred {
        return todo_container_empty_id(todo)
      }
    end

    return context_container_empty_id(todo)
  end

  def empty_criteria_met
    return @todo_was_deferred_from_active_state ||
      @todo_was_blocked_from_active_state ||
      @todo_was_destroyed_from_deferred_state ||
      @todo_was_created_deferred ||
      @todo_was_blocked_from_completed_state ||
      @todo_was_created_blocked
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
        container_id = project_container_empty_id(@original_item) if @remaining_in_context == 0
        container_id = "deferred_pending_container-empty-d" if todo_was_removed_from_deferred_or_blocked_container && @remaining_deferred_or_pending_count == 0
        container_id = "completed_container-empty-d" if @completed_count && @completed_count == 0 && !@todo.completed?
      }
      page.deferred { container_id = todo_container_empty_id(@original_item) if @remaining_in_context == 0 }
      page.calendar { container_id = "#{@original_item_due_id}_container-empty-d" if @old_due_empty }
      page.tag      {
        container_id = "hidden_container-empty-d" if (@remaining_hidden_count == 0 && !@todo.hidden? && @todo_hidden_state_changed) ||
          (@remaining_hidden_count == 0 && @todo.completed? && @original_item_was_hidden)
        container_id = "deferred_pending_container-empty-d" if (todo_was_removed_from_deferred_or_blocked_container && @remaining_deferred_or_pending_count == 0) ||
          (@original_item_was_deferred && @remaining_deferred_or_pending_count == 0 && (@todo.completed? || @tag_was_removed))
        container_id = "completed_container-empty-d" if @completed_count && @completed_count == 0 && !@todo.completed?
      }
      page.context  {
        container_id = context_container_empty_id(@original_item) if @remaining_in_context == 0
        container_id = "deferred_pending_container-empty-d" if todo_was_removed_from_deferred_or_blocked_container && @remaining_deferred_or_pending_count == 0
        container_id = "completed_container-empty-d" if @completed_count && @completed_count == 0 && !@todo.completed?
      }
      page.todo     { container_id = context_container_empty_id(@original_item) if @remaining_in_context == 0 }
      page.done     { container_id = "completed_#{@original_completed_period}_container-empty-d" if @remaining_in_context == 0 }
      page.all_done { container_id = "all-done-empty-nd" if @remaining_in_context == 0 }
    end
    return container_id.blank? ? "" : "$(\"##{container_id}\").slideDown(100);".html_safe
  end

end
