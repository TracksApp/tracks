class TodosController < ApplicationController

  skip_before_filter :login_required, :only => [:index, :tag]
  prepend_before_filter :login_or_feed_token_required, :only => [:index, :tag]
  append_before_filter :find_and_activate_ready, :only => [:index, :list_deferred]

  protect_from_forgery :except => :check_deferred

  def index
    @source_view = params['_source_view'] || 'todo'

    init_data_for_sidebar unless mobile?

    @todos = current_user.todos.includes(Todo::DEFAULT_INCLUDES)
    @todos = @todos.limit(sanitize(params[:limit])) if params[:limit]

    @not_done_todos = get_not_done_todos

    @projects = current_user.projects.includes(:default_context)
    @contexts = current_user.contexts
    @contexts_to_show = current_user.contexts.active
    @projects_to_show = current_user.projects.active

    # If you've set no_completed to zero, the completed items box isn't shown
    # on the home page
    max_completed = current_user.prefs.show_number_completed
    @done = current_user.todos.completed.limit(max_completed).includes(Todo::DEFAULT_INCLUDES) unless max_completed == 0

    respond_to do |format|
      format.html  do
        @page_title = t('todos.task_list_title')
        # Set count badge to number of not-done, not hidden context items
        @count = current_user.todos.active.not_hidden.count(:all)
        @todos_without_project = @not_done_todos.select{|t|t.project.nil?}
      end
      format.m do
        @page_title = t('todos.mobile_todos_page_title')
        @home = true

        cookies[:mobile_url]= { :value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
        determine_down_count

        render :action => 'index'.freeze
      end
      format.text  do
        # somehow passing Mime::TEXT using content_type to render does not work
        headers['Content-Type'.freeze]=Mime::TEXT.to_s
        render :content_type => Mime::TEXT
      end
      format.xml do
        @xml_todos = params[:limit_to_active_todos] ? @not_done_todos : @todos
        render :xml => @xml_todos.to_xml( *todo_xml_params )
      end
      format.any(:rss, :atom) do
        @feed_title = 'Tracks Actions'.freeze
        @feed_description = "Actions for #{current_user.display_name}"
      end
      format.ics
    end
  end

  def new
    @projects = current_user.projects.active
    @contexts = current_user.contexts
    respond_to do |format|
      format.m {
        @new_mobile = true
        @return_path=cookies[:mobile_url] ? cookies[:mobile_url] : mobile_path
        @mobile_from_context = current_user.contexts.find(params[:from_context]) if params[:from_context]
        @mobile_from_project = current_user.projects.find(params[:from_project]) if params[:from_project]
        if params[:from_project] && !params[:from_context]
          # we have a project but not a context -> use the default context
          @mobile_from_context = @mobile_from_project.default_context
        end
      }
    end
  end

  def create
    @source_view = params['_source_view'] || 'todo'
    @default_context = current_user.contexts.where(:name => params['default_context_name']).first
    @default_project = current_user.projects.where(:name => params['default_project_name']).first if params['default_project_name'].present?

    @tag_name = params['_tag_name']

    is_multiple = params[:todo] && params[:todo][:multiple_todos] && !params[:todo][:multiple_todos].nil?
    if is_multiple
      create_multiple
    else
      p = Todos::TodoCreateParamsHelper.new(params, current_user)
      p.parse_dates unless mobile?
      tag_list = p.tag_list

      @todo = current_user.todos.build
      @todo.assign_attributes(p.attributes)
      p.add_errors(@todo)

      if @todo.errors.empty?
        @todo.add_predecessor_list(p.predecessor_list)
        @saved = @todo.save
        @todo.tag_with(tag_list) if @saved && tag_list.present?
        @todo.update_state_from_project if @saved
        @todo.block! if @todo.should_be_blocked?
      else
        @saved = false
      end

      @todo_was_created_deferred = @todo.deferred?
      @todo_was_created_blocked = @todo.pending?
      @not_done_todos = [@todo] if p.new_project_created || p.new_context_created
      @new_project_created = p.new_project_created
      @new_context_created = p.new_context_created

      respond_to do |format|
        format.html do
          redirect_to :action => "index"
        end
        format.m do
          @return_path=cookies[:mobile_url] ? cookies[:mobile_url] : mobile_path
          if @saved
            onsite_redirect_to @return_path
          else
            @projects = current_user.projects
            @contexts = current_user.contexts
            render :action => "new"
          end
        end
        format.js do
          if @saved
            determine_down_count
            @contexts = current_user.contexts
            @projects = current_user.projects
            @context = @todo.context
            @project = @todo.project
            @initial_context_name = params['default_context_name']
            @initial_project_name = params['default_project_name']
            @initial_tags = params['initial_tag_list']
            @status_message = t('todos.added_new_next_action')
            @status_message += ' ' + t('todos.to_tickler') if @todo.deferred?
            @status_message += ' ' + t('todos.in_pending_state') if @todo.pending?
            @status_message += ' ' + t('todos.in_hidden_state') if @todo.hidden?
            @status_message = t('todos.added_new_project') + ' / ' + @status_message if @new_project_created
            @status_message = t('todos.added_new_context') + ' / ' + @status_message if @new_context_created
          end
          render :action => 'create'
        end
        format.xml do
          if @saved
            head :created, :location => todo_url(@todo)
          else
            render_failure @todo.errors.to_xml.html_safe, 409
          end
        end
      end
    end
  end

  def create_multiple
    p = Todos::TodoCreateParamsHelper.new(params, current_user)
    tag_list = p.tag_list

    @not_done_todos = []
    @build_todos = []
    @todos = []
    errors = []
    @predecessor = nil
    validates = true

    # first build all todos and check if they would validate on save
    params[:todo][:multiple_todos].split("\n").map do |line|
      if line.present? #ignore blank lines
        @todo = current_user.todos.build({:description => line, :context_id => p.context_id, :project_id => p.project_id})
        validates &&= @todo.valid?

        @build_todos << @todo
      end
    end

    # if all todos validate, then save them and add predecessors and tags
    if validates
      @build_todos.each do |todo|
        @saved = todo.save
        validates &&= @saved

        if @predecessor && @saved && p.sequential?
          todo.add_predecessor(@predecessor)
          todo.block!
        end

        todo.tag_with(tag_list) if @saved && tag_list.present?

        @todos << todo
        @not_done_todos << todo if p.new_context_created || p.new_project_created
        @predecessor = todo
      end
    else
      @todos = @build_todos
      @saved = false
    end

    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js do
        determine_down_count if @saved
        @contexts = current_user.contexts if p.new_context_created
        @projects = current_user.projects if p.new_project_created
        @new_project_created = p.new_project_created
        @new_context_created = p.new_context_created
        @initial_context_name = params['default_context_name']
        @initial_project_name = params['default_project_name']
        @initial_tags = params['initial_tag_list']
        if @saved && @todos.size > 0
          @default_tags = @todos[0].project.default_tags unless @todos[0].project.nil?
        else
          @multiple_error = @todos.size > 0 ? "" : t('todos.next_action_needed')
          @saved = false
          @default_tags = current_user.projects.where(:name => @initial_project_name).default_tags if @initial_project_name.present?
        end

        @status_message = @todos.size > 1 ? t('todos.added_new_next_action_plural') : t('todos.added_new_next_action_singular')
        @status_message = t('todos.added_new_project') + ' / ' + @status_message if p.new_project_created
        @status_message = t('todos.added_new_context') + ' / ' + @status_message if p.new_context_created

        render :action => 'create_multiple'
      end
      format.xml do
        if @saved
          head :created, :location => context_url(@todos[0].context)
        else
          render :xml => @todos[0].errors.to_xml, :status => 422
        end
      end
    end
  end

  def edit
    @todo = current_user.todos.find(params['id'])
    @source_view = params['_source_view'] || 'todo'
    @tag_name = params['_tag_name']
    respond_to do |format|
      format.js
      format.m {
        @projects = current_user.projects.active
        @contexts = current_user.contexts
        @edit_mobile = true
        @return_path=cookies[:mobile_url] ? cookies[:mobile_url] : mobile_path
      }
    end
  end

  def show
    @todo = current_user.todos.find(params['id'])
    respond_to do |format|
      format.m { render :action => 'show' }
      format.xml { render :xml => @todo.to_xml( *todo_xml_params ) }
    end
  end

  def add_predecessor
    @source_view = params['_source_view'] || 'todo'
    @predecessor = current_user.todos.find(params['predecessor'])
    @predecessors = @predecessor.predecessors
    @todo = current_user.todos.includes(Todo::DEFAULT_INCLUDES).find(params['successor'])
    @original_state = @todo.state
    unless @predecessor.completed?
      begin
        @todo.add_predecessor(@predecessor)
        @todo.block! unless @todo.pending?
        @saved = @todo.save
      rescue ActiveRecord::RecordInvalid
        @saved = false
      end

      @status_message = t('todos.added_dependency', :dependency => @predecessor.description)
      @status_message += t('todos.set_to_pending', :task => @todo.description) unless @original_state == 'pending'
    else
      @saved = false
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_predecessor
    @source_view = params['_source_view'] || 'todo'
    @todo = current_user.todos.includes(Todo::DEFAULT_INCLUDES).find(params['id'])
    @predecessor = current_user.todos.find(params['predecessor'])
    @predecessors = @predecessor.predecessors
    @successor = @todo
    @removed = @successor.remove_predecessor(@predecessor)
    determine_remaining_in_container_count(@todo)
    respond_to do |format|
      format.js
    end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    @todo = current_user.todos.find(params['id'])

    @source_view = params['_source_view'] || 'todo'

    @original_item = current_user.todos.build(@todo.attributes)  # create a (unsaved) copy of the original todo
    @original_item_due = @todo.due
    @original_item_was_deferred = @todo.deferred?
    @original_item_was_pending = @todo.pending?
    @original_item_was_hidden = @todo.hidden?
    @original_item_context_id = @todo.context_id
    @original_item_project_id = @todo.project_id
    @original_completed_period = DoneTodos.completed_period(@todo.completed_at)
    @todo_was_completed_from_deferred_or_blocked_state = @original_item_was_deferred || @original_item_was_pending

    @saved = @todo.toggle_completion!

    @todo_was_blocked_from_completed_state = @todo.pending? # since we toggled_completion the previous state was completed

    # check if this todo has a related recurring_todo. If so, create next todo
    @new_recurring_todo = check_for_next_todo(@todo) if @saved

    @predecessors = @todo.uncompleted_predecessors
    if @saved
      if @todo.completed?
        @pending_to_activate = @todo.activate_pending_todos
      else
        @active_to_block = @todo.block_successors
      end
    end

    respond_to do |format|
      format.js do
        if @saved
          determine_remaining_in_container_count(@todo)
          determine_down_count
          determine_completed_count
          determine_deferred_tag_count(params['_tag_name']) if source_view_is(:tag)
          @wants_redirect_after_complete = @todo.completed?  && !@todo.project_id.nil? && current_user.prefs.show_project_on_todo_done && !source_view_is(:project)
          if source_view_is :calendar
            @original_item_due_id = get_due_id_for_calendar(@original_item_due)
            @old_due_empty = is_old_due_empty(@original_item_due_id)
          end
        end
        render
      end
      format.xml { render :xml => @todo.to_xml( *todo_xml_params ) }
      format.html do
        if @saved
          # TODO: I think this will work, but can't figure out how to test it
          notify(:notice, t("todos.action_marked_complete", :description => @todo.description, :completed => @todo.completed? ? 'complete' : 'incomplete'))
          redirect_to :action => "index"
        else
          notify(:notice, t("todos.action_marked_complete_error", :description => @todo.description, :completed => @todo.completed? ? 'complete' : 'incomplete'), "index")
          redirect_to :action =>  "index"
        end
      end
      format.m {
        if @saved
          if cookies[:mobile_url]
            old_path = cookies[:mobile_url]
            cookies[:mobile_url] = {:value => nil, :secure => SITE_CONFIG['secure_cookies']}
            notify(:notice, t("todos.action_marked_complete", :description => @todo.description, :completed => @todo.completed? ? 'complete' : 'incomplete'))
            onsite_redirect_to old_path
          else
            notify(:notice, t("todos.action_marked_complete", :description => @todo.description, :completed => @todo.completed? ? 'complete' : 'incomplete'))
            onsite_redirect_to todos_path(:format => 'm')
          end
        else
          render :action => "edit", :format => :m
        end
      }
    end
  end

  def toggle_star
    @todo = current_user.todos.find(params['id'])
    @todo.toggle_star!
    @saved = true # cannot determine error
    respond_to do |format|
      format.js
      format.xml { render :xml => @todo.to_xml( *todo_xml_params ) }
      format.html { redirect_to request.referrer}
      format.m {
        if cookies[:mobile_url]
          old_path = cookies[:mobile_url]
          cookies[:mobile_url] = {:value => nil, :secure => SITE_CONFIG['secure_cookies']}
          notify(:notice, "Star toggled")
          onsite_redirect_to old_path
        else
          notify(:notice, "Star toggled")
          onsite_redirect_to todos_path(:format => 'm')
        end
      }
    end
  end

  def change_context
    # change context if you drag a todo to another context
    @todo = current_user.todos.find(params[:id])
    @original_item_context_id = @todo.context_id
    @original_item = current_user.todos.build(@todo.attributes)  # create a (unsaved) copy of the original todo
    @context = current_user.contexts.find(params[:todo][:context_id])
    @todo.context = @context
    @saved = @todo.save

    @context_changed = true
    @status_message = t('todos.context_changed', :name => @context.name)
    determine_down_count
    determine_remaining_in_container_count(@original_item)

    respond_to do |format|
      format.js  { render :action => :update }
      format.xml { render :xml => @todo.to_xml( *todo_xml_params ) }
    end
  end

  def update
    @source_view = params['_source_view'] || 'todo'

    @todo = current_user.todos.find(params['id'])
    @original_item = current_user.todos.build(@todo.attributes)  # create a (unsaved) copy of the original todo

    cache_attributes_from_before_update # TODO: remove in favor of @original_item

    update_tags
    update_project
    update_context
    update_due_and_show_from_dates
    update_completed_state
    update_dependencies
    update_attributes_of_todo

    begin
      @saved = @todo.save!
    rescue ActiveRecord::RecordInvalid => exception
      record = exception.record
      if record.is_a?(Dependency)
        record.errors.each { |key,value| @todo.errors[key] << value }
      end
      @saved = false
    end


    provide_project_or_context_for_view

    # this is set after save and cleared after reload, so save it here
    @removed_predecessors = @todo.removed_predecessors

    @todo.reload # refresh context and project object too (not only their id's)

    update_dependency_state
    update_todo_state_if_project_changed

    determine_changes_by_this_update
    determine_remaining_in_container_count( (@context_changed || @project_changed) ? @original_item : @todo)
    determine_down_count
    determine_deferred_tag_count(sanitize(params['_tag_name'])) if source_view_is(:tag)

    @todo.touch_predecessors if @original_item_description != @todo.description

    respond_to do |format|
      format.js {
        @status_message = @todo.deferred? ? t('todos.action_saved_to_tickler') : t('todos.action_saved')
        @status_message = t('todos.added_new_project') + ' / ' + @status_message if @new_project_created
        @status_message = t('todos.added_new_context') + ' / ' + @status_message if @new_context_created
      }
      format.xml { render :xml => @todo.to_xml( *todo_xml_params ) }
      format.m do
        if @saved
          do_mobile_todo_redirection
        else
          render :action => "edit", :format => :m
        end
      end
    end
  end

  def provide_project_or_context_for_view
    # see application_helper:source_view_key, used in shown partials
    if source_view_is :project
      @project = @todo.project
    elsif source_view_is :context
      @context = @todo.context
    end
  end

  def destroy
    @source_view = params['_source_view'] || 'todo'
    @todo = current_user.todos.find(params['id'])
    @original_item = current_user.todos.build(@todo.attributes)  # create a (unsaved) copy of the original todo
    @original_item_due = @todo.due
    @context_id = @todo.context_id
    @project_id = @todo.project_id
    @todo_was_destroyed = true
    @todo_was_destroyed_from_deferred_state = @todo.deferred?
    @todo_was_destroyed_from_pending_state = @todo.pending?
    @todo_was_destroyed_from_deferred_or_pending_state = @todo_was_destroyed_from_deferred_state || @todo_was_destroyed_from_pending_state

    @uncompleted_predecessors = []
    @todo.uncompleted_predecessors.each do |predecessor|
      @uncompleted_predecessors << predecessor
    end

    activated_successor_count = 0
    @pending_to_activate = []
    @todo.pending_successors.each do |successor|
      if successor.uncompleted_predecessors.size == 1
        @pending_to_activate << successor
        activated_successor_count += 1
      end
    end

    @saved = @todo.destroy

    # check if this todo has a related recurring_todo. If so, create next todo
    @new_recurring_todo = check_for_next_todo(@todo) if @saved

    respond_to do |format|

      format.html do
        if @saved
          message = t('todos.action_deleted_success')
          if activated_successor_count > 0
            message += " activated #{pluralize(activated_successor_count, 'pending action')}"
          end
          notify :notice, message, 2.0
          redirect_to :action => 'index'
        else
          notify :error, t('todos.action_deleted_error'), 2.0
          redirect_to :action => 'index'
        end
      end

      format.js do
        if @saved
          determine_down_count
          if source_view_is_one_of(:todo, :deferred, :project, :context, :tag)
            determine_remaining_in_container_count(@todo)
          elsif source_view_is :calendar
            @original_item_due_id = get_due_id_for_calendar(@original_item_due)
            @old_due_empty = is_old_due_empty(@original_item_due_id)
          end
        end
        render
      end

      format.xml { render :text => '200 OK. Action deleted.', :status => 200 }

    end
  end

  def done
    @source_view = 'done'
    @page_title = t('todos.completed_tasks_title')

    @done_today, @done_rest_of_week, @done_rest_of_month = DoneTodos.done_todos_for_container(current_user.todos)
    @count = @done_today.size + @done_rest_of_week.size + @done_rest_of_month.size

    respond_to do |format|
      format.html
      format.xml do
        completed_todos = current_user.todos.completed
        render :xml => completed_todos.to_xml( *todo_xml_params )
      end
    end
  end

  def all_done
    @source_view = 'done'
    @page_title = t('todos.completed_tasks_title')

    @done = current_user.todos.completed.includes(Todo::DEFAULT_INCLUDES).reorder('completed_at DESC').paginate :page => params[:page], :per_page => 20
    @count = @done.size
  end

  def list_deferred
    @source_view = 'deferred'
    @page_title = t('todos.deferred_tasks_title')

    @contexts_to_show = @contexts = current_user.contexts
    @projects_to_show = @projects = current_user.projects

    includes = params[:format]=='xml' ? [:context, :project] : Todo::DEFAULT_INCLUDES

    @not_done_todos = current_user.todos.deferred.includes(includes).reorder('show_from') + current_user.todos.pending.includes(includes)
    @todos_without_project = @not_done_todos.select{|t|t.project.nil?}
    @down_count = @count = @not_done_todos.size

    respond_to do |format|
      format.html do
        init_not_done_counts
        init_project_hidden_todo_counts
        init_data_for_sidebar unless mobile?
      end
      format.m
      format.xml { render :xml => @not_done_todos.to_xml( *todo_xml_params ) }
    end
  end

  # Check for any due tickler items, activate them
  # Called by periodically_call_remote
  def check_deferred
    @due_tickles = current_user.deferred_todos.find_and_activate_ready
    respond_to do |format|
      format.html { redirect_to home_path }
      format.js
    end
  end

  def filter_to_context
    context = current_user.contexts.find(params['context']['id'])
    redirect_to context_todos_path(context, :format => 'm')
  end

  def filter_to_project
    project = current_user.projects.find(params['project']['id'])
    redirect_to project_todos_path(project, :format => 'm')
  end

  # /todos/tag/[tag_name] shows all the actions tagged with tag_name
  def tag
    get_params_for_tag_view
    @page_title = t('todos.tagged_page_title', :tag_name => @tag_title)
    @source_view = params['_source_view'] || 'tag'

    init_data_for_sidebar unless mobile?

    todos_with_tag_ids = find_todos_with_tag_expr(@tag_expr)

    @not_done_todos = todos_with_tag_ids.
      active.not_hidden.
      reorder('todos.due IS NULL, todos.due ASC, todos.created_at ASC').
      includes(Todo::DEFAULT_INCLUDES)
    @hidden_todos = todos_with_tag_ids.
      hidden.
      reorder('todos.completed_at DESC, todos.created_at DESC').
      includes(Todo::DEFAULT_INCLUDES)
    @deferred_todos = todos_with_tag_ids.
      deferred.
      reorder('todos.show_from ASC, todos.created_at DESC').
      includes(Todo::DEFAULT_INCLUDES)
    @pending_todos = todos_with_tag_ids.
      blocked.
      reorder('todos.show_from ASC, todos.created_at DESC').
      includes(Todo::DEFAULT_INCLUDES)
    @todos_without_project = @not_done_todos.select{|t| t.project.nil?}

    # If you've set no_completed to zero, the completed items box isn't shown on
    # the tag page
    @done = todos_with_tag_ids.completed.
      limit(current_user.prefs.show_number_completed).
      reorder('todos.completed_at DESC').
      includes(Todo::DEFAULT_INCLUDES)

    @projects = current_user.projects
    @contexts = current_user.contexts
    @contexts_to_show = @contexts.active
    @projects_to_show = @projects.active

    # Set defaults for new_action
    @initial_tags = @tag_name

    # Set count badge to number of items with this tag
    @not_done_todos.empty? ? @count = 0 : @count = @not_done_todos.size
    @down_count = @count

    respond_to do |format|
      format.html
      format.m {
        cookies[:mobile_url]= {:value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
      }
      format.text {
        render :action => 'index', :layout => false, :content_type => Mime::TEXT
      }
    end
  end

  def done_tag
    done_by_tag_setup

    completed_todos = current_user.todos.completed.with_tag(@tag.id)

    @done_today = get_done_today(completed_todos)
    @done_rest_of_week = get_done_rest_of_week(completed_todos)
    @done_rest_of_month = get_done_rest_of_month(completed_todos)
    @count = @done_today.size + @done_rest_of_week.size + @done_rest_of_month.size

    render :template => 'todos/done'
  end

  def all_done_tag
    done_by_tag_setup
    @done = current_user.todos.completed.with_tag(@tag.id).reorder('completed_at DESC').includes(Todo::DEFAULT_INCLUDES).paginate :page => params[:page], :per_page => 20
    @count = @done.size
    render :template => 'todos/all_done'
  end

  def done_by_tag_setup
    @source_view = params['_source_view'] || 'done'
    @tag_name = sanitize(params[:name]) # sanitize to prevent XSS vunerability!
    @page_title = t('todos.all_completed_tagged_page_title', :tag_name => @tag_name)
    @tag = Tag.where(:name => @tag_name).first_or_create
  end


  def tags
    # TODO: limit to current_user
    tags_beginning = Tag.where('name like ?', params[:term]+'%')
    tags_all = Tag.where('name like ?', '%'+params[:term]+'%')
    tags_all= tags_all - tags_beginning

    respond_to do |format|
      format.autocomplete { render :text => for_autocomplete(tags_beginning+tags_all, params[:term]) }
    end
  end

  def defer
    @source_view = params['_source_view'] || 'todo'
    numdays = params['days'].to_i

    @todo = current_user.todos.find(params[:id])
    @original_item = current_user.todos.build(@todo.attributes)  # create a (unsaved) copy of the original todo

    @original_item_context_id = @todo.context_id
    @todo_deferred_state_changed = true
    @new_context_created = false
    @due_date_changed = false
    @tag_was_removed = false
    @todo_hidden_state_changed = false
    @todo_was_deferred_from_active_state = @todo.show_from.nil?

    @todo.show_from = (@todo.show_from || @todo.user.date) + numdays.days
    @saved = @todo.save
    @status_message = t('todos.action_saved_to_tickler')

    determine_down_count
    determine_remaining_in_container_count(@todo)
    source_view do |page|
      page.project {
        @remaining_undone_in_project = current_user.projects.find(@todo.project_id).todos.not_completed.count
        @original_item_project_id = @todo.project_id
      }
      page.tag {
        determine_deferred_tag_count(params['_tag_name'])
      }
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {render :action => 'update'}
      format.m {
        notify(:notice, t("todos.action_deferred", :description => @todo.description))
        do_mobile_todo_redirection
      }
    end
  end

  def list_hidden
    @hidden = current_user.todos.hidden
    respond_to do |format|
      format.xml {
        render :xml => @hidden.to_xml( *todo_xml_params )
      }
    end
  end

  def get_not_completed_for_predecessor(relation, todo_id=nil)
    items = relation.todos.not_completed.
      where('(LOWER(todos.description) LIKE ?)', "%#{params[:term].downcase}%")
    items = items.where("AND NOT(todos.id=?)", todo_id) unless todo_id.nil?

    items.
      includes(:context, :project).
      reorder('description ASC').
      limit(10)
  end

  def auto_complete_for_predecessor
    unless params['id'].nil?
      get_todo_from_params
      # Begin matching todos in current project, excluding @todo itself
      @items = get_not_completed_for_predecessor(@todo.project, @todo.id) unless @todo.project.nil?
      # Then look in the current context, excluding @todo itself
      @items = get_not_completed_for_predecessor(@todo.context, @todo.id) unless !@items.empty? || @todo.context.nil?
      # Match todos in other projects, excluding @todo itself
      @items = get_not_completed_for_predecessor(current_user, @todo.id) unless !@items.empty?
    else
      # New todo - TODO: Filter on current project in project view
      @items = get_not_completed_for_predecessor(current_user)
    end
    render :inline => format_dependencies_as_json_for_auto_complete(@items)
  end

  def convert_to_project
    todo = current_user.todos.find(params[:id])
    @project = ProjectFromTodo.new(todo).create

    if @project.valid?
      redirect_to project_url(@project)
    else
      flash[:error] = "Could not create project from todo: #{@project.errors.full_messages[0]}"
      onsite_redirect_to request.env["HTTP_REFERER"] || root_url
    end
  end

  def show_notes
    @todo = current_user.todos.find(params['id'])
    @return_path=cookies[:mobile_url] ? cookies[:mobile_url] : mobile_path
    respond_to do |format|
      format.html {
        redirect_to home_path, "Viewing note of todo is not implemented"
      }
      format.m   {
        render :action => "show_notes"
      }
    end
  end

  def attachment
    id = params[:id]
    filename = params[:filename]
    attachment = current_user.attachments.find(id)

    if attachment
      send_file(attachment.file.path,
        disposition: 'attachment',
        type: 'message/rfc822')
    else
      head :not_found
    end
  end

  private

  def set_group_view_by
    @group_view_by = params['_group_view_by'] || cookies['group_view_by'] || 'context'
  end

  def do_mobile_todo_redirection
    if cookies[:mobile_url]
      old_path = cookies[:mobile_url]
      cookies[:mobile_url] = {:value => nil, :secure => SITE_CONFIG['secure_cookies']}
      onsite_redirect_to old_path
    else
      onsite_redirect_to todos_path(:format => 'm')
    end
  end

  def get_todo_from_params
    # TODO: this was a :append_before but was removed to tune performance per
    # method. Reconsider re-enabling it
    @todo = current_user.todos.find(params['id'])
  end

  def find_and_activate_ready
    current_user.deferred_todos.find_and_activate_ready
  end

  def tag_title(tag_expr)
    and_list = tag_expr.inject([]) { |s,tag_list| s << tag_list.join(',') }
    return and_list.join(' AND ')
  end

  def get_params_for_tag_view
    filter_format_for_tag_view

    # use sanitize to prevent XSS attacks
    @tag_expr = []
    @tag_expr << sanitize(params[:name]).split(',')
    @tag_expr << sanitize(params[:and]).split(',') if params[:and]

    i = 1
    while params['and'+i.to_s]
      @tag_expr << sanitize(params['and'+i.to_s]).split(',')
      i=i+1
    end

    @single_tag = @tag_expr.size == 1 && @tag_expr[0].size == 1
    @tag_name = @tag_expr[0][0]
    @tag_title = @single_tag ? @tag_name : tag_title(@tag_expr)
  end

  def filter_format_for_tag_view
    # routes for tag view do not set :format
    if params[:name] =~ /.*\.m$/
      set_format_for_tag_view(:m)
    elsif params[:name] =~ /.*\.txt$/
      set_format_for_tag_view(:txt)
      # set content-type to text/plain or it remains text/html
      response.headers["Content-Type"] = 'text/plain'
    elsif params[:format].nil?
      # if no format is given, default to html
      # note that if url has ?format=m, we should not overwrite it here
      request.format = :html
      params[:format] = :html
    end
  end

  def set_format_for_tag_view(format)
    # tag name ends with .m, set format to :m en remove .m from name
    request.format = format
    params[:format] = format
    params[:name] = params[:name].chomp(".#{format.to_s}")
end

  def get_ids_from_tag_expr(tag_expr)
    ids = []
    tag_expr.each do |tag_list|
      id_list = []
      tag_list.each do |tag|
        tag = Tag.where(:name => tag).first
        id_list << tag.id if tag
      end
      ids << id_list
    end
    return ids
  end

  def find_todos_with_tag_expr(tag_expr)
    # optimize for the common case: selecting only one tag
    if @single_tag
      tag = Tag.where(:name => @tag_name).first
      tag_id = tag.nil? ? -1 : tag.id
      return current_user.todos.with_tag(tag_id)
    end

    tag_ids = get_ids_from_tag_expr(tag_expr)
    todos = current_user.todos
    tag_ids.each do |ids|
      todos = todos.with_tags(ids) unless ids.nil? || ids.empty?
    end
    return todos
  end

  def determine_down_count
    source_view do |from|
      from.todo do
        @down_count = current_user.todos.active.not_hidden.count
      end
      from.context do
        context_id = @original_item_context_id || @todo.context_id
        todos = current_user.contexts.find(context_id).todos.not_completed

        if @todo.context.hidden?
          # include hidden todos
          @down_count = todos.count
        else
          # exclude hidden_todos
          @down_count = todos.not_hidden.count
        end
      end
      from.project do
        unless @todo.project_id == nil
          @down_count = current_user.projects.find(@todo.project_id).todos.active_or_hidden.count
        end
      end
      from.deferred do
        @down_count = current_user.todos.deferred_or_blocked.count
      end
      from.tag do
        @tag_name = params['_tag_name']
        @tag = Tag.where(:name => @tag_name).first
        if @tag.nil?
          @tag = Tag.new(:name => @tag_name)
        end
        @down_count = current_user.todos.with_tag(@tag.id).active.not_hidden.count
      end
    end
  end

  def find_todos_in_project_container(todo)
    if todo.project.nil?
      # container with todos without project
      todos_in_container = current_user.todos.where(:project_id => nil)
    else
      todos_in_container = current_user.projects.find(todo.project_id).todos
    end
  end

  def find_todos_in_container_and_target_container(todo, target_todo)
    if @group_view_by == 'context'
      todos_in_container = current_user.contexts.find(todo.context_id).todos
      todos_in_target_container = current_user.contexts.find(@todo.context_id).todos
    else
      todos_in_container = find_todos_in_project_container(todo)
      todos_in_target_container = find_todos_in_project_container(@todo)
    end
    return todos_in_container, todos_in_target_container
  end

  def determine_remaining_in_container_count(todo = @todo)
    source_view do |from|
      from.deferred {
        todos_in_container, todos_in_target_container = find_todos_in_container_and_target_container(todo, @todo)
        @remaining_in_context = todos_in_container.deferred_or_blocked.count
        @target_context_count = todos_in_target_container.deferred_or_blocked.count
      }
      from.todo {
        todos_in_container, todos_in_target_container = find_todos_in_container_and_target_container(todo, @todo)
        @remaining_in_context = todos_in_container.active.not_hidden.count
        @target_context_count = todos_in_target_container.active.not_hidden.count
      }
      from.tag {
        tag = Tag.where(:name => params['_tag_name']).first
        tag = Tag.new(:name => params['tag']) if tag.nil?

        todos_in_container, todos_in_target_container = find_todos_in_container_and_target_container(todo, @todo)

        @remaining_in_context = todos_in_container.active.not_hidden.with_tag(tag.id).count
        @target_context_count = todos_in_target_container.active.not_hidden.with_tag(tag.id).count
        @remaining_hidden_count = current_user.todos.hidden.with_tag(tag.id).count
        @remaining_deferred_or_pending_count = current_user.todos.with_tag(tag.id).deferred_or_blocked.count
      }
      from.project {
        project_id = @project_changed ? @original_item_project_id : @todo.project_id
        @remaining_deferred_or_pending_count = current_user.projects.find(project_id).todos.deferred_or_blocked.count

        if @todo_was_completed_from_deferred_or_blocked_state
          @remaining_in_context = @remaining_deferred_or_pending_count
        else
          @remaining_in_context = current_user.projects.find(project_id).todos.active_or_hidden.count
        end

        @target_context_count = current_user.projects.find(project_id).todos.active.count
      }
      from.calendar {
        @target_context_count = @new_due_id.blank? ? 0 : count_old_due_empty(@new_due_id)
      }
      from.context {
        context = current_user.contexts.find(todo.context_id)
        @remaining_deferred_or_pending_count = context.todos.deferred_or_blocked.count

        remaining_actions_in_context = context.todos(true).active
        remaining_actions_in_context = remaining_actions_in_context.not_hidden if !context.hidden?
        @remaining_in_context = remaining_actions_in_context.count

        if @todo_was_deferred_or_blocked
          actions_in_target = current_user.contexts.find(@todo.context_id).todos(true).active
          actions_in_target = actions_in_target.not_hidden if !context.hidden?
        else
          actions_in_target = @todo.context.todos.deferred_or_blocked
        end
        @target_context_count = actions_in_target.count
      }
      from.done {
        @remaining_in_context = DoneTodos.remaining_in_container(current_user.todos, @original_completed_period)
      }
      from.all_done {
        @remaining_in_context = current_user.todos.completed.count
      }
    end
  end

  def find_completed(relation, id, include_hidden)
    todos = relation.find(id).todos.completed
    todos = todos.not_hidden if !include_hidden
    return todos
  end

  def determine_completed_count
    todos=nil

    source_view do |from|
      from.todo    { todos = current_user.todos.not_hidden.completed }
      from.context { todos = find_completed(current_user.contexts, @todo.context_id, @todo.context.hidden?) }
      from.project { todos = find_completed(current_user.projects, @todo.project_id, @todo.project.hidden?) unless @todo.project_id.nil? }
      from.tag     { todos = current_user.todos.with_tag(@tag.id).completed }
    end

    @completed_count = todos.nil? ? 0 : todos.count
  end

  def determine_deferred_tag_count(tag_name)
    tag = Tag.where(:name => tag_name).first
    # tag.nil? should normally not happen, but is a workaround for #929
    @remaining_deferred_or_pending_count = tag.nil? ? 0 : current_user.todos.deferred.with_tag(tag.id).count
  end

  def check_for_next_todo(todo)
    # check if this todo has a related recurring_todo. If so, create next todo
    new_recurring_todo = nil
    recurring_todo = nil
    if todo.from_recurring_todo?
      recurring_todo = todo.recurring_todo

      # check if there are active todos belonging to this recurring todo. only
      # add new one if all active todos are completed
      if recurring_todo.todos.active.count == 0

        # check for next todo either from the due date or the show_from date
        date_to_check = todo.due || todo.show_from

        # if both due and show_from are nil, check for a next todo from now
        date_to_check ||= Time.zone.now

        if recurring_todo.active? && recurring_todo.continues_recurring?(date_to_check)

          # shift the reference date to yesterday if date_to_check is furher in
          # the past. This is to make sure we do not get older todos for overdue
          # todos. I.e. checking a daily todo that is overdue with 5 days will
          # create a new todo which is overdue by 4 days if we don't shift the
          # date. Discard the time part in the compare. We pick yesterday so
          # that new todos due for today will be created instead of new todos
          # for tomorrow.
          date = date_to_check.at_midnight >= Time.zone.now.at_midnight ? date_to_check : Time.zone.now-1.day

          new_recurring_todo = TodoFromRecurringTodo.new(current_user, recurring_todo).create(date)
        end
      end
    end
    return new_recurring_todo
  end

  def get_due_id_for_calendar(due)
    return "" if due.nil?
    due_today_date = Time.zone.now
    due_this_week_date = Time.zone.now.end_of_week
    due_next_week_date = due_this_week_date + 7.days
    due_this_month_date = Time.zone.now.end_of_month
    if due <= due_today_date
      new_due_id = "due_today"
    elsif due <= due_this_week_date
      new_due_id = "due_this_week"
    elsif due <= due_next_week_date
      new_due_id = "due_next_week"
    elsif due <= due_this_month_date
      new_due_id = "due_this_month"
    else
      new_due_id = "due_after_this_month"
    end
    return new_due_id
  end

  def is_old_due_empty(id)
    return 0 == count_old_due_empty(id)
  end

  def count_old_due_empty(id)
    due_today_date = Time.zone.now
    due_this_week_date = Time.zone.now.end_of_week
    due_next_week_date = due_this_week_date + 7.days
    due_this_month_date = Time.zone.now.end_of_month
    case id
    when "due_today"
      return current_user.todos.not_completed.where('todos.due <= ?', due_today_date).count
    when "due_this_week"
      return current_user.todos.not_completed.where('todos.due > ? AND todos.due <= ?', due_today_date, due_this_week_date).count
    when "due_next_week"
      return current_user.todos.not_completed.where('todos.due > ? AND todos.due <= ?', due_this_week_date, due_next_week_date).count
    when "due_this_month"
      return current_user.todos.not_completed.where('todos.due > ? AND todos.due <= ?', due_next_week_date, due_this_month_date).count
    when "due_after_this_month"
      return current_user.todos.not_completed.where('todos.due > ?', due_this_month_date).count
    else
      raise Exception.new, "unknown due id for calendar: '#{id}'"
    end
  end

  def cache_attributes_from_before_update
    @original_item_context_id = @todo.context_id
    @original_item_project_id = @todo.project_id
    @original_item_was_deferred = @todo.deferred?
    @original_item_was_hidden = @todo.hidden?
    @original_item_was_pending = @todo.pending?
    @original_item_due = @todo.due
    @original_item_due_id = get_due_id_for_calendar(@todo.due)
    @original_item_predecessor_list = @todo.predecessors.map{|t| t.specification}.join(', ')
    @original_item_description = @todo.description
    @todo_was_deferred_or_blocked = @todo.deferred? || @todo.pending?
  end

  def update_project
    @project_changed = false
    if params['todo']['project_id'].blank? && !params['project_name'].nil?
      if params['project_name'].blank?
        project = Project.null_object
      else
        project = current_user.projects.where(:name => params['project_name'].strip).first
        unless project
          project = current_user.projects.build
          project.name = params['project_name'].strip
          project.save
          @new_project_created = true
          @new_container = project
          @not_done_todos = [@todo]
        end
      end
      params["todo"]["project_id"] = project.id
      @project_changed = @original_item_project_id != params["todo"]["project_id"] = project.id
    end
  end

  def update_todo_state_if_project_changed
    if @project_changed
      @todo.update_state_from_project
      @remaining_undone_in_project = current_user.projects.find(@original_item_project_id).todos.active.count if source_view_is :project
    end
  end

  def update_context
    @context_changed = false
    if params['todo']['context_id'].blank? && params['context_name'].present?
      @context = current_user.contexts.where(:name => params['context_name'].strip).first
      if @context.nil?
        @new_context = current_user.contexts.build
        @new_context.name = params['context_name'].strip
        @new_context.save
        @new_context_created = true
        @new_container = @new_context
        @not_done_todos = [@todo]
        @context = @new_context
      end
      params["todo"]["context_id"] = @context.id
      @context_changed = @original_item_context_id != params["todo"]["context_id"] = @context.id
    end
  end

  def update_tags
    if params[:tag_list]
      @todo.tag_with(params[:tag_list])
      @todo.tags(true) #force a reload for proper rendering
    end
  end

  def parse_date_for_update(date, error_msg)
    begin
      parse_date_per_user_prefs(date)
    rescue
      @todo.errors[:base] << error_msg
    end
  end

  def update_date_for_update(key)
    params['todo'][key] = params["todo"].has_key?(key) ? parse_date_for_update(params["todo"][key], t("todos.error.invalid_#{key}_date")) : ""
  end

  def update_due_and_show_from_dates
    %w{ due show_from }.each {|date| update_date_for_update(date) }
  end

  def update_completed_state
    if params['done'] == '1' && !@todo.completed?
      @todo.complete!
      @todo.activate_pending_todos
    end
    # strange. if checkbox is not checked, there is no 'done' in params.
    # Therefore I've used the negation
    if !(params['done'] == '1') && @todo.completed?
      @todo.activate!
      @todo.block_successors
    end
  end

  def update_dependencies
    @todo.add_predecessor_list(params[:predecessor_list])
  end

  def update_dependency_state
    # assumes @todo.save was called so that the predecessor_list is persistent
    if @original_item_predecessor_list != params[:predecessor_list]
      # Possible state change with new dependencies
      if @todo.uncompleted_predecessors.empty?
        @todo.activate! if @todo.state == 'pending' # Activate pending if no uncompleted predecessors
      else
        @todo.block! if @todo.state == 'active' # Block active if we got uncompleted predecessors
      end
    end
  end

  def update_attributes_of_todo
    # TODO: duplication with todo_create_params_helper
    @todo.attributes = params.require(:todo).permit(
        :context_id, :project_id, :description, :notes,
        :due, :show_from, :state)
  end

  def determine_changes_by_this_update
    @todo_was_activated_from_deferred_state = @todo.active? && @original_item_was_deferred
    @todo_was_activated_from_pending_state = @todo.active? && @original_item_was_pending
    @todo_was_deferred_from_active_state = @todo.deferred? && !@original_item_was_deferred
    @todo_was_blocked_from_active_state = @todo.pending? && !@original_item_was_pending

    @todo_deferred_state_changed = @original_item_was_deferred != @todo.deferred?
    @todo_pending_state_changed = @original_item_was_pending != @todo.pending?
    @todo_hidden_state_changed = @original_item_was_hidden != @todo.hidden?

    @due_date_changed = @original_item_due != @todo.due

    source_view do |page|
      page.calendar do
        @old_due_empty = is_old_due_empty(@original_item_due_id)
        @new_due_id = get_due_id_for_calendar(@todo.due)
      end
      page.tag do
        @tag_name = params['_tag_name']
        @tag_was_removed = !@todo.has_tag?(@tag_name)
      end
      page.context do
        @todo_should_be_hidden = @todo_hidden_state_changed && @todo.hidden?
      end
    end
  end

  # all completed todos [today@00:00, today@now]
  def get_done_today(completed_todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    start_of_this_day = Time.zone.now.beginning_of_day
    completed_todos.completed_after(start_of_this_day).includes(includes[:include])
  end

  def get_done_in_period(completed_todos, before, after, includes = {:include => Todo::DEFAULT_INCLUDES})
    completed_todos.completed_before(before).completed_after(after).includes(includes[:include])
  end

  # all completed todos [begin_of_week, start_of_today]
  def get_done_rest_of_week(completed_todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    get_done_in_period(completed_todos, Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_week)
  end

  # all completed todos [begin_of_month, begin_of_week]
  def get_done_rest_of_month(completed_todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    get_done_in_period(completed_todos, Time.zone.now.beginning_of_week, Time.zone.now.beginning_of_month)
  end

  def get_not_done_todos
      # TODO: refactor text feed for done todos to todos/done.text, not /todos.text?done=true
    if params[:done]
      not_done_todos = current_user.todos.completed.completed_after(Time.zone.now - params[:done].to_i.days)
    else
      not_done_todos = current_user.todos.active.not_hidden
    end

    not_done_todos = not_done_todos.
      reorder("todos.due IS NULL, todos.due ASC, todos.created_at ASC").
      includes(Todo::DEFAULT_INCLUDES)

    not_done_todos = not_done_todos.limit(sanitize(params[:limit])) if params[:limit]

    if params[:due]
      due_within_when = Time.zone.now + params['due'].to_i.days
      not_done_todos = not_done_todos.where('todos.due <= ?', due_within_when)
    end

    if params[:tag]
      tag = Tag.where(:name => params['tag']).first
      not_done_todos = not_done_todos.where('taggings.tag_id = ?', tag.id)
    end

    if params[:context_id]
      context = current_user.contexts.find(params[:context_id])
      not_done_todos = not_done_todos.where('context_id' => context.id)
    end

    if params[:project_id]
      project = current_user.projects.find(params[:project_id])
      not_done_todos = not_done_todos.where('project_id' => project)
    end

    return not_done_todos
  end

  def onsite_redirect_to(destination)
    uri = URI.parse(destination)

    if uri.query.present?
      redirect_to("#{uri.path}?#{uri.query}")
    else
      redirect_to(uri.path)
    end
  end

end
