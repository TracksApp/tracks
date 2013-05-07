class TodosController < ApplicationController

  skip_before_filter :login_required, :only => [:index, :calendar, :tag]
  prepend_before_filter :login_or_feed_token_required, :only => [:index, :calendar, :tag]
  append_before_filter :find_and_activate_ready, :only => [:index, :list_deferred]

  protect_from_forgery :except => :check_deferred
  
  def index
    @source_view = params['_source_view'] || 'todo'
    init_data_for_sidebar unless mobile?
    
    @todos = current_user.todos.includes(Todo::DEFAULT_INCLUDES)
    
    # TODO: refactor text feed for done todos to todos/done.text, not /todos.text?done=true
    if params[:done]
      @not_done_todos = current_user.todos.completed.completed_after(Time.zone.now - params[:done].to_i.days)
    else
      @not_done_todos = current_user.todos.active.not_hidden
    end
    
    @not_done_todos = @not_done_todos.
      reorder("todos.due IS NULL, todos.due ASC, todos.created_at ASC").
      includes(Todo::DEFAULT_INCLUDES)

    if params[:limit]
      @not_done_todos = @not_done_todos.limit(sanitize(params[:limit]))
      @todos = @todos.limit(sanitize(params[:limit]))
    end
    
    if params[:due]
      due_within_when = Time.zone.now + params['due'].to_i.days
      @not_done_todos = @not_done_todos.where('todos.due <= ?', due_within_when)
    end
    
    if params[:tag]
      tag = Tag.find_by_name(params['tag'])
      @not_done_todos = @not_done_todos.where('taggings.tag_id = ?', tag.id)
    end
    
    if params[:context_id]
      context = current_user.contexts.find(params[:context_id])
      @not_done_todos = @not_done_todos.where('context_id' => context.id)
    end
    
    if params[:project_id]
      project = current_user.projects.find(params[:project_id])
      @not_done_todos = @not_done_todos.where('project_id' => project)
    end
    
    @projects = current_user.projects.includes(:default_context)
    @contexts = current_user.contexts
    @contexts_to_show = current_user.contexts.active
    
    # If you've set no_completed to zero, the completed items box isn't shown
    # on the home page
    max_completed = current_user.prefs.show_number_completed
    @done = current_user.todos.completed.limit(max_completed).includes(Todo::DEFAULT_INCLUDES) unless max_completed == 0

    respond_to do |format|
      format.html  do
        @page_title = t('todos.task_list_title')
        # Set count badge to number of not-done, not hidden context items
        @count = current_user.todos.active.not_hidden.count(:all)
      end
      format.m do
        @page_title = t('todos.mobile_todos_page_title')
        @home = true
  
        cookies[:mobile_url]= { :value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
        determine_down_count
  
        render :action => 'index'
      end
      format.text  do
        # somehow passing Mime::TEXT using content_type to render does not work
        headers['Content-Type']=Mime::TEXT.to_s
        render :content_type => Mime::TEXT
      end
      format.xml   { render :xml => @todos.to_xml( *to_xml_params ) }
      format.rss   { @feed_title, @feed_description = 'Tracks Actions', "Actions for #{current_user.display_name}" }
      format.atom  { @feed_title, @feed_description = 'Tracks Actions', "Actions for #{current_user.display_name}" }
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
        @mobile_from_context = current_user.contexts.find_by_id(params[:from_context]) if params[:from_context]
        @mobile_from_project = current_user.projects.find_by_id(params[:from_project]) if params[:from_project]
        if params[:from_project] && !params[:from_context]
          # we have a project but not a context -> use the default context
          @mobile_from_context = @mobile_from_project.default_context
        end
      }
    end
  end

  def create
    @source_view = params['_source_view'] || 'todo'
    @default_context = current_user.contexts.find_by_name(params['default_context_name'])
    @default_project = current_user.projects.find_by_name(params['default_project_name']) unless params['default_project_name'].blank?

    @tag_name = params['_tag_name']

    is_multiple = params[:todo] && params[:todo][:multiple_todos] && !params[:todo][:multiple_todos].nil?
    if is_multiple
      create_multiple
    else
      p = TodoCreateParamsHelper.new(params, prefs)
      p.parse_dates() unless mobile?
      tag_list = p.tag_list
      predecessor_list = p.predecessor_list

      @todo = current_user.todos.build(p.attributes)

      if p.project_specified_by_name?
        project = current_user.projects.find_or_create_by_name(p.project_name)
        @new_project_created = project.new_record_before_save?
        @todo.project_id = project.id
      elsif !(p.project_id.nil? || p.project_id.blank?)
        project = current_user.projects.find_by_id(p.project_id)
        @todo.errors[:project] << "unknown" if project.nil?
      end

      if p.context_specified_by_name?
        context = current_user.contexts.find_or_create_by_name(p.context_name)
        @new_context_created = context.new_record_before_save?
        @not_done_todos = [@todo] if @new_context_created
        @todo.context_id = context.id
      elsif !(p.context_id.nil? || p.context_id.blank?)
        context = current_user.contexts.find_by_id(p.context_id)
        @todo.errors[:context] << "unknown" if context.nil?
      end

      if @todo.errors.empty?
        @todo.starred= (params[:new_todo_starred]||"").include? "true" if params[:new_todo_starred]
        @todo.add_predecessor_list(predecessor_list)
        @saved = @todo.save
        @todo.update_state_from_project if @saved
      else
        @saved = false
      end

      unless ( !@saved ) || tag_list.blank?
        @todo.tag_with(tag_list)
        @todo.tags.reload
      end

      if @saved
        @todo.block! unless @todo.uncompleted_predecessors.empty? || @todo.state == 'project_hidden'
        @saved = @todo.save
      end

      @todo.reload if @saved
      @todo_was_created_deferred = @todo.deferred?
      @todo_was_created_blocked = @todo.pending?

      respond_to do |format|
        format.html { redirect_to :action => "index" }
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
            @contexts = current_user.contexts if @new_context_created
            @projects = current_user.projects if @new_project_created
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
    if project_specified_by_name(params[:project_name])
      project = current_user.projects.find_or_create_by_name(params[:project_name])
      @new_project_created = project.new_record_before_save?
      @project_id = project.id
    end

    if context_specified_by_name(params[:context_name])
      context = current_user.contexts.find_or_create_by_name(params[:context_name])
      @new_context_created = context.new_record_before_save?
      @not_done_todos = [] if @new_context_created
      @context_id = context.id
    end

    tag_list = params[:tag_list]

    @sequential = !params[:todos_sequential].blank? && params[:todos_sequential]=='true'

    @todos_init = []
    @predecessor = nil
    validates = true
    errors = []
    
    # first build all todos and check if they would validate on save
    params[:todo][:multiple_todos].split("\n").map do |line|
      unless line.blank?
        @todo = current_user.todos.build(
          :description => line)
        @todo.project_id = @project_id
        @todo.context_id = @context_id
        validates = false if @todo.invalid?
        
        @todos_init << @todo
      end
    end
    
    # if all todos validate, then save them and add predecessors and tags
    @todos = []
    if validates
      @todos_init.each do |todo|
        @saved = todo.save
        validates = validates && @saved

        if @predecessor && @saved && @sequential
          todo.add_predecessor(@predecessor)
          todo.block!
        end

        unless (@saved == false) || tag_list.blank?
          todo.tag_with(tag_list)
          todo.tags.reload
        end

        @todos << todo
        @not_done_todos << todo if @new_context_created
        @predecessor = todo
      end
    else
      @todos = @todos_init
      @saved = false
    end
    
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js do
        determine_down_count if @saved
        @contexts = current_user.contexts if @new_context_created
        @projects = current_user.projects if @new_project_created
        @initial_context_name = params['default_context_name']
        @initial_project_name = params['default_project_name']
        @initial_tags = params['initial_tag_list']
        if @saved && @todos.size > 0
          @default_tags = @todos[0].project.default_tags unless @todos[0].project.nil?
        else
          @multiple_error = @todos.size > 0 ? "" : t('todos.next_action_needed')
          @saved = false
          @default_tags = current_user.projects.find_by_name(@initial_project_name).default_tags unless @initial_project_name.blank?
        end

        @status_message = @todos.size > 1 ? t('todos.added_new_next_action_plural') : t('todos.added_new_next_action_singular')
        @status_message = t('todos.added_new_project') + ' / ' + @status_message if @new_project_created
        @status_message = t('todos.added_new_context') + ' / ' + @status_message if @new_context_created

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
    @todo = current_user.todos.find_by_id(params['id'])
    respond_to do |format|
      format.m { render :action => 'show' }
      format.xml { render :xml => @todo.to_xml( *to_xml_params ) }
    end
  end

  def add_predecessor
    @source_view = params['_source_view'] || 'todo'
    @predecessor = current_user.todos.find_by_id(params['predecessor'])
    @predecessors = @predecessor.predecessors
    @todo = current_user.todos.includes(Todo::DEFAULT_INCLUDES).find_by_id(params['successor'])
    @original_state = @todo.state
    unless @predecessor.completed?
      @todo.add_predecessor(@predecessor)
      @todo.block! unless @todo.pending?
      @saved = @todo.save

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
    @todo = current_user.todos.includes(Todo::DEFAULT_INCLUDES).find_by_id(params['id'])
    @predecessor = current_user.todos.find_by_id(params['predecessor'])
    @predecessors = @predecessor.predecessors
    @successor = @todo
    @removed = @successor.remove_predecessor(@predecessor)
    determine_remaining_in_context_count
    respond_to do |format|
      format.js
    end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    @todo = current_user.todos.find(params['id'])
    @source_view = params['_source_view'] || 'todo'
    @original_item_due = @todo.due
    @original_item_was_deferred = @todo.deferred?
    @original_item_was_pending = @todo.pending?
    @original_item_was_hidden = @todo.hidden?
    @original_item_context_id = @todo.context_id
    @original_item_project_id = @todo.project_id
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
          determine_remaining_in_context_count(@todo.context_id)
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
      format.xml { render :xml => @todo.to_xml( *to_xml_params ) }
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
    @todo = current_user.todos.find_by_id(params['id'])
    @todo.toggle_star!
    @saved = true # cannot determine error
    respond_to do |format|
      format.js
      format.xml { render :xml => @todo.to_xml( *to_xml_params ) }
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
    @todo = current_user.todos.find_by_id(params[:id])
    @original_item_context_id = @todo.context_id
    @context = current_user.contexts.find_by_id(params[:todo][:context_id])
    @todo.context = @context
    @saved = @todo.save
    current_user.contexts.find(@original_item_context_id).touch

    @context_changed = true
    @status_message = t('todos.context_changed', :name => @context.name)
    determine_down_count
    determine_remaining_in_context_count(@original_item_context_id)

    respond_to do |format|
      format.js  { render :action => :update }
      format.xml { render :xml => @todo.to_xml( *to_xml_params ) }
    end
  end

  def update
    @todo = current_user.todos.find_by_id(params['id'])
    @source_view = params['_source_view'] || 'todo'
    # init_data_for_sidebar unless mobile?

    cache_attributes_from_before_update

    update_tags
    update_project
    update_context
    update_due_and_show_from_dates
    update_completed_state
    update_dependencies
    update_attributes_of_todo

    @saved = @todo.save

    # this is set after save and cleared after reload, so save it here
    @removed_predecessors = @todo.removed_predecessors

    @todo.reload # refresh context and project object too (not only their id's)

    update_dependency_state
    update_todo_state_if_project_changed

    determine_changes_by_this_update
    determine_remaining_in_context_count(@context_changed ? @original_item_context_id : @todo.context_id)
    determine_down_count
    determine_deferred_tag_count(params['_tag_name']) if source_view_is(:tag)

    @todo.touch_predecessors if @original_item_description != @todo.description

    respond_to do |format|
      format.js {
        @status_message = @todo.deferred? ? t('todos.action_saved_to_tickler') : t('todos.action_saved')
        @status_message = t('todos.added_new_project') + ' / ' + @status_message if @new_project_created
        @status_message = t('todos.added_new_context') + ' / ' + @status_message if @new_context_created
      }
      format.xml { render :xml => @todo.to_xml( *to_xml_params ) }
      format.m do
        if @saved
          do_mobile_todo_redirection
        else
          render :action => "edit", :format => :m
        end
      end
    end
  end

  def destroy
    @source_view = params['_source_view'] || 'todo'
    @todo = current_user.todos.find_by_id(params['id'])
    @original_item_due = @todo.due
    @context_id = @todo.context_id
    @project_id = @todo.project_id
    @todo_was_destroyed_from_deferred_state = @todo.deferred?
    @todo_was_destroyed_from_pending_state = @todo.pending?
    @todo_was_destroyed_from_deferred_or_pending_state = @todo_was_destroyed_from_deferred_state || @todo_was_destroyed_from_pending_state

    @uncompleted_predecessors = []
    @todo.uncompleted_predecessors.each do |predecessor|
      @uncompleted_predecessors << predecessor
    end

    # activate successors if they only depend on this todo
    activated_successor_count = 0
    @pending_to_activate = []
    @todo.pending_successors.each do |successor|
      successor.uncompleted_predecessors.delete(@todo)
      if successor.uncompleted_predecessors.empty?
        successor.activate!
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
          if source_view_is_one_of(:todo, :deferred, :project, :context)
            determine_remaining_in_context_count(@context_id)
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

    @done_today, @done_this_week, @done_this_month = DoneTodos.done_todos_for_container(current_user)
    @count = @done_today.size + @done_this_week.size + @done_this_month.size

    respond_to do |format|
      format.html
      format.xml do 
        completed_todos = current_user.todos.completed
        render :xml => completed_todos.to_xml( *to_xml_params ) 
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

    includes = params[:format]=='xml' ? [:context, :project] : Todo::DEFAULT_INCLUDES

    @not_done_todos = current_user.todos.deferred.includes(includes) + current_user.todos.pending.includes(includes)
    @down_count = @count = @not_done_todos.size

    respond_to do |format|
      format.html do
        init_not_done_counts
        init_project_hidden_todo_counts
        @active_projects = current_user.projects.active
        @active_contexts = current_user.contexts.active
        @hidden_projects = current_user.projects.hidden
        @hidden_contexts = current_user.contexts.hidden
        @completed_projects = current_user.projects.completed
      end
      format.m
      format.xml { render :xml => @not_done_todos.to_xml( *to_xml_params ) }
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
    context = current_user.contexts.find_by_id(params['context']['id'])
    redirect_to context_todos_path(context, :format => 'm')
  end

  def filter_to_project
    project = current_user.projects.find_by_id(params['project']['id'])
    redirect_to project_todos_path(project, :format => 'm')
  end

  # /todos/tag/[tag_name] shows all the actions tagged with tag_name
  def tag
    get_params_for_tag_view
    @page_title = t('todos.tagged_page_title', :tag_name => @tag_title)
    @source_view = params['_source_view'] || 'tag'

    if mobile?
      # mobile tags are routed with :name ending on .m. So we need to chomp it
      @tag_name = @tag_name.chomp('.m')
    else
      init_data_for_sidebar
    end

    todos_with_tag_ids = find_todos_with_tag_expr(@tag_expr)

    @not_done_todos = todos_with_tag_ids.
      active.not_hidden.
      reorder('todos.due IS NULL, todos.due ASC, todos.created_at ASC').
      includes(Todo::DEFAULT_INCLUDES)
    @hidden_todos = todos_with_tag_ids.
      hidden.
      reorder('todos.completed_at DESC, todos.created_at DESC').
      includes(Todo::DEFAULT_INCLUDES)
    @deferred = todos_with_tag_ids.
      deferred.
      reorder('todos.show_from ASC, todos.created_at DESC').
      includes(Todo::DEFAULT_INCLUDES)
    @pending = todos_with_tag_ids.
      blocked.
      reorder('todos.show_from ASC, todos.created_at DESC').
      includes(Todo::DEFAULT_INCLUDES)

    # If you've set no_completed to zero, the completed items box isn't shown on
    # the tag page
    @done = todos_with_tag_ids.completed.
      limit(current_user.prefs.show_number_completed).
      reorder('todos.completed_at DESC').
      includes(Todo::DEFAULT_INCLUDES)

    @projects = current_user.projects
    @contexts = current_user.contexts
    @contexts_to_show = @contexts.reject {|x| x.hide? }

    # Set defaults for new_action
    @initial_tags = @tag_name
    unless @not_done_todos.empty?
      @context = current_user.contexts.find(@not_done_todos.first.context_id)
    end

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
    @source_view = params['_source_view'] || 'tag'
    @tag_name = sanitize(params[:name]) # sanitize to prevent XSS vunerability!
    @page_title = t('todos.completed_tagged_page_title', :tag_name => @tag_name)
    @tag = Tag.find_by_name(@tag_name)
    @tag = Tag.new(:name => @tag_name) if @tag.nil?

    completed_todos = current_user.todos.completed.with_tag(@tag.id)

    @done_today = get_done_today(completed_todos)
    @done_this_week = get_done_this_week(completed_todos)
    @done_this_month = get_done_this_month(completed_todos)
    @count = @done_today.size + @done_this_week.size + @done_this_month.size

    render :template => 'todos/done'
  end

  def all_done_tag
    @source_view = params['_source_view'] || 'tag'
    @tag_name = sanitize(params[:name]) # sanitize to prevent XSS vunerability!
    @page_title = t('todos.all_completed_tagged_page_title', :tag_name => @tag_name)
    @tag = Tag.find_by_name(@tag_name)
    @tag = Tag.new(:name => @tag_name) if @tag.nil?

    @done = current_user.todos.completed.with_tag(@tag.id).reorder('completed_at DESC').includes(Todo::DEFAULT_INCLUDES).paginate :page => params[:page], :per_page => 20
    @count = @done.size
    render :template => 'todos/all_done'
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

    @todo = current_user.todos.find_by_id(params[:id])
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
    determine_remaining_in_context_count(@todo.context_id)
    source_view do |page|
      page.project {
        @remaining_undone_in_project = current_user.projects.find_by_id(@todo.project_id).todos.not_completed.count
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

  def calendar
    @source_view = params['_source_view'] || 'calendar'
    @page_title = t('todos.calendar_page_title')

    @projects = current_user.projects

    due_today_date = Time.zone.now
    due_this_week_date = due_today_date.end_of_week
    due_next_week_date = due_this_week_date + 7.days
    due_this_month_date = due_today_date.end_of_month
    included_tables = Todo::DEFAULT_INCLUDES

    @due_today = current_user.todos.not_completed.
      where('todos.due <= ?', due_today_date).
      includes(included_tables).
      reorder("due")
    @due_this_week = current_user.todos.not_completed.
      where('todos.due > ? AND todos.due <= ?', due_today_date, due_this_week_date).
      includes(included_tables).
      reorder("due")
    @due_next_week = current_user.todos.not_completed.
      where('todos.due > ? AND todos.due <= ?', due_this_week_date, due_next_week_date).
      includes(included_tables).
      reorder("due")
    @due_this_month = current_user.todos.not_completed.
      where('todos.due > ? AND todos.due <= ?', due_next_week_date, due_this_month_date).
      includes(included_tables).
      reorder("due")
    @due_after_this_month = current_user.todos.not_completed.
      where('todos.due > ?', due_this_month_date).
      includes(included_tables).
      reorder("due")

    @count = current_user.todos.not_completed.are_due.count

    respond_to do |format|
      format.html
      format.ics   {
        @due_all = current_user.todos.not_completed.are_due.reorder("due")
        render :action => 'calendar', :layout => false, :content_type => Mime::ICS
      }
      format.xml {
        @due_all = current_user.todos.not_completed.are_due.reorder("due")
        render :xml => @due_all.to_xml( *to_xml_params )
      }
    end
  end

  def list_hidden
    @hidden = current_user.todos.hidden
    respond_to do |format|
      format.xml {
        render :xml => @hidden.to_xml( *to_xml_params )
      }
    end
  end

  def auto_complete_for_predecessor
    unless params['id'].nil?
      get_todo_from_params
      # Begin matching todos in current project, excluding @todo itself
      @items = @todo.project.todos.not_completed.
        where('(LOWER(todos.description) LIKE ?) AND NOT(todos.id=?)', "%#{params[:term].downcase}%", @todo.id).
        includes(:context, :project).
        reorder('description ASC').
        limit(10) unless @todo.project.nil?
      # Then look in the current context, excluding @todo itself
      @items = @todo.context.todos.not_completed
        where('(LOWER(todos.description) LIKE ?) AND NOT(todos.id=?)', "%#{params[:term].downcase}%", @todo.id).
        includes(:context, :project).
        reorder('description ASC').
        limit(10) unless !@items.empty? || @todo.context.nil?
      # Match todos in other projects, excluding @todo itself
      @items = current_user.todos.not_completed.
        where('(LOWER(todos.description) LIKE ?) AND NOT(todos.id=?)', "%#{params[:term].downcase}%", @todo.id).
        includes(:context, :project).
        reorder('description ASC').
        limit(10) unless !@items.empty?
    else
      # New todo - TODO: Filter on current project in project view
      @items = current_user.todos.not_completed.
        where('(LOWER(todos.description) LIKE ?)', "%#{params[:term].downcase}%").
        includes(:context, :project).
        reorder('description ASC').
        limit(10)
    end
    render :inline => format_dependencies_as_json_for_auto_complete(@items)
  end

  def convert_to_project
    todo = current_user.todos.find_by_id(params[:id])
    @project = Project.create_from_todo(todo)
   
    if @project.valid?
      redirect_to project_url(@project)
    else
      flash[:error] = "Could not create project from todo: #{@project.errors.full_messages[0]}"
      onsite_redirect_to request.env["HTTP_REFERER"] || root_url
    end
  end

  def show_notes
    @todo = current_user.todos.find_by_id(params['id'])
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

  private

  def do_mobile_todo_redirection
    if cookies[:mobile_url]
      old_path = cookies[:mobile_url]
      cookies[:mobile_url] = {:value => nil, :secure => SITE_CONFIG['secure_cookies']}
      onsite_redirect_to old_path
    else
      onsite_redirect_to todos_path(:format => 'm')
    end
  end

  def to_xml_params
    if params[:limit_fields] == 'index'
      return [:only => [:id, :created_at, :updated_at, :completed_at] ]
    else
      return [:except => :user_id, :include => [:tags, :predecessors, :successors] ]
    end
  end

  def get_todo_from_params
    # TODO: this was a :append_before but was removed to tune performance per
    # method. Reconsider re-enabling it
    @todo = current_user.todos.find_by_id(params['id'])
  end

  def find_and_activate_ready
    current_user.deferred_todos.find_and_activate_ready
  end

  def tag_title(tag_expr)
    and_list = tag_expr.inject([]) { |s,tag_list| s << tag_list.join(',') }
    return and_list.join(' AND ')
  end

  def get_params_for_tag_view
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

  def get_ids_from_tag_expr(tag_expr)
    ids = []
    tag_expr.each do |tag_list|
      id_list = []
      tag_list.each do |tag|
        tag = Tag.find_by_name(tag)
        id_list << tag.id if tag
      end
      ids << id_list
    end
    return ids
  end

  def find_todos_with_tag_expr(tag_expr)
    # optimize for the common case: selecting only one tag
    if @single_tag
      tag = Tag.find_by_name(@tag_name)
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
        todos = current_user.contexts.find_by_id(context_id).todos.not_completed

        if @todo.context.hide?
          # include hidden todos
          @down_count = todos.count
        else
          # exclude hidden_todos
          @down_count = todos.not_hidden.count
        end
      end
      from.project do
        unless @todo.project_id == nil
          @down_count = current_user.projects.find_by_id(@todo.project_id).todos.active_or_hidden.count
        end
      end
      from.deferred do
        @down_count = current_user.todos.deferred_or_blocked.count
      end
      from.tag do
        @tag_name = params['_tag_name']
        @tag = Tag.find_by_name(@tag_name)
        if @tag.nil?
          @tag = Tag.new(:name => @tag_name)
        end
        @down_count = current_user.todos.with_tag(@tag.id).active.not_hidden.count
      end
    end
  end

  def determine_remaining_in_context_count(context_id = @todo.context_id)
    source_view do |from|
      from.deferred {
        # force reload to todos to get correct count and not a cached one
        @remaining_in_context = current_user.contexts.find_by_id(context_id).todos.deferred_or_blocked.count
        @target_context_count = current_user.contexts.find_by_id(@todo.context_id).todos.deferred_or_blocked.count
      }
      from.tag {
        tag = Tag.find_by_name(params['_tag_name'])
        if tag.nil?
          tag = Tag.new(:name => params['tag'])
        end
        @remaining_deferred_or_pending_count = current_user.todos.with_tag(tag.id).deferred_or_blocked.count
        @remaining_in_context = current_user.contexts.find_by_id(context_id).todos.active.not_hidden.with_tag(tag.id).count
        @target_context_count = current_user.contexts.find_by_id(@todo.context_id).todos.active.not_hidden.with_tag(tag.id).count
        @remaining_hidden_count = current_user.todos.hidden.with_tag(tag.id).count
      }
      from.project {
        project_id = @project_changed ? @original_item_project_id : @todo.project_id
        @remaining_deferred_or_pending_count = current_user.projects.find_by_id(project_id).todos.deferred_or_blocked.count

        if @todo_was_completed_from_deferred_or_blocked_state
          @remaining_in_context = @remaining_deferred_or_pending_count
        else
          @remaining_in_context = current_user.projects.find_by_id(project_id).todos.active_or_hidden.count
        end

        @target_context_count = current_user.projects.find_by_id(project_id).todos.active.count
      }
      from.calendar {
        @target_context_count = @new_due_id.blank? ? 0 : count_old_due_empty(@new_due_id)
      }
      from.context {
        context = current_user.contexts.find_by_id(context_id)
        @remaining_deferred_or_pending_count = context.todos.deferred_or_blocked.count

        remaining_actions_in_context = context.todos(true).active
        remaining_actions_in_context = remaining_actions_in_context.not_hidden if !context.hide?
        @remaining_in_context = remaining_actions_in_context.count

        if @todo_was_deferred_or_blocked
          actions_in_target = current_user.contexts.find_by_id(@todo.context_id).todos(true).active
          actions_in_target = actions_in_target.not_hidden if !context.hide?
        else
          actions_in_target = @todo.context.todos.deferred_or_blocked
        end
        @target_context_count = actions_in_target.count
      }
    end
    @remaining_in_context = current_user.contexts.find_by_id(context_id).todos(true).active.not_hidden.count if !@remaining_in_context
    @target_context_count = current_user.contexts.find_by_id(@todo.context_id).todos(true).active.not_hidden.count if !@target_context_count
  end

  def determine_completed_count
    source_view do |from|
      from.todo do
        @completed_count = current_user.todos.not_hidden.completed.count
      end
      from.context do
        todos = current_user.contexts.find_by_id(@todo.context_id).todos.completed
        todos = todos.not_hidden if !@todo.context.hidden?
        @completed_count = todos.count
      end
      from.project do
        unless @todo.project_id == nil
          todos = current_user.projects.find_by_id(@todo.project_id).todos.completed
          todos = todos.not_hidden if !@todo.project.hidden?
          @completed_count = todos.count
        end
      end
      from.tag do
        @completed_count = current_user.todos.with_tag(@tag.id).completed.count
      end
    end
  end

  def determine_deferred_tag_count(tag_name)
    tag = Tag.find_by_name(tag_name)
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
        date_to_check = todo.due.nil? ? todo.show_from : todo.due

        # if both due and show_from are nil, check for a next todo from now
        date_to_check = Time.zone.now if date_to_check.nil?

        if recurring_todo.active? && recurring_todo.has_next_todo(date_to_check)

          # shift the reference date to yesterday if date_to_check is furher in
          # the past. This is to make sure we do not get older todos for overdue
          # todos. I.e. checking a daily todo that is overdue with 5 days will
          # create a new todo which is overdue by 4 days if we don't shift the
          # date. Discard the time part in the compare. We pick yesterday so
          # that new todos due for today will be created instead of new todos
          # for tomorrow.
          date = date_to_check.at_midnight >= Time.zone.now.at_midnight ? date_to_check : Time.zone.now-1.day

          new_recurring_todo = create_todo_from_recurring_todo(recurring_todo, date.at_midnight)
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
    @project_changed = false;
    if params['todo']['project_id'].blank? && !params['project_name'].nil?
      if params['project_name'] == 'None'
        project = Project.null_object
      else
        project = current_user.projects.find_by_name(params['project_name'].strip)
        unless project
          project = current_user.projects.build
          project.name = params['project_name'].strip
          project.save
          @new_project_created = true
        end
      end
      params["todo"]["project_id"] = project.id
      @project_changed = @original_item_project_id != params["todo"]["project_id"] = project.id
    end
  end

  def update_todo_state_if_project_changed
    if @project_changed
      @todo.update_state_from_project
      @remaining_undone_in_project = current_user.projects.find_by_id(@original_item_project_id).todos.active.count if source_view_is :project
    end
  end

  def update_context
    @context_changed = false
    if params['todo']['context_id'].blank? && !params['context_name'].blank?
      context = current_user.contexts.find_by_name(params['context_name'].strip)
      unless context
        @new_context = current_user.contexts.build
        @new_context.name = params['context_name'].strip
        @new_context.save
        @new_context_created = true
        @not_done_todos = [@todo]
        context = @new_context
      end
      params["todo"]["context_id"] = context.id
      @context_changed = @original_item_context_id != params["todo"]["context_id"] = context.id
    end
  end

  def update_tags
    if params[:tag_list]
      @todo.tag_with(params[:tag_list])
      @todo.tags(true) #force a reload for proper rendering
    end
  end

  def update_due_and_show_from_dates
    if params["todo"].has_key?("due")
      begin
        params["todo"]["due"] = parse_date_per_user_prefs(params["todo"]["due"])
      rescue
        @todo.errors[:base] << "Invalid due date"
      end
    else
      params["todo"]["due"] = ""
    end
    if params['todo']['show_from']
      begin
        params['todo']['show_from'] = parse_date_per_user_prefs(params['todo']['show_from'])
      rescue
        @todo.errors[:base] << "Invalid show from date"
      end
    end
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
    @todo.attributes = params["todo"]
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

  def project_specified_by_name(project_name)
    return false unless params['project_id'].blank?
    return false if project_name.blank?
    return false if project_name == 'None'
    true
  end

  def context_specified_by_name(context_name)
    return false unless params['context_id'].blank?
    return false if context_name.blank?
    true
  end

  def determine_non_uniq_todo
    # for calendar view. TODO: unused
    all_list_uniq_ids = (@due_today.map(&:id) + @due_this_week.map(&:id) +
      @due_next_week.map(&:id) + @due_this_month.map(&:id) + @due_after_this_month.map(&:id)).uniq
    all_list_count = @due_today.count + @due_this_week.count +
      @due_next_week.count + @due_this_month.count + @due_after_this_month.count

    return !( all_list_uniq_ids.length == all_list_count )
  end

  # all completed todos [today@00:00, today@now]
  def get_done_today(completed_todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    start_of_this_day = Time.zone.now.beginning_of_day
    completed_todos.completed_after(start_of_this_day).all(includes)
  end

  # all completed todos [begin_of_week, start_of_today]
  def get_done_this_week(completed_todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    start_of_this_week = Time.zone.now.beginning_of_week
    start_of_this_day = Time.zone.now.beginning_of_day
    completed_todos.completed_before(start_of_this_day).completed_after(start_of_this_week).all(includes)
  end

  # all completed todos [begin_of_month, begin_of_week]
  def get_done_this_month(completed_todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    start_of_this_month = Time.zone.now.beginning_of_month
    start_of_this_week = Time.zone.now.beginning_of_week
    completed_todos.completed_before(start_of_this_week).completed_after(start_of_this_month).all(includes)
  end
  
  class TodoCreateParamsHelper

    def initialize(params, prefs)
      @params = params['request'] || params
      @prefs = prefs
      @attributes = params['request'] && params['request']['todo']  || params['todo']

      if @attributes && @attributes[:tags]
        # for single tags, @attributed[:tags] returns a hash. For multiple tags,
        # it with return an array of hashes. Make sure it is always an array of hashes
        @attributes[:tags][:tag] = [@attributes[:tags][:tag]] unless @attributes[:tags][:tag].class == Array
        # the REST api may use <tags> which will collide with tags association, so rename tags to add_tags
        @attributes[:add_tags] = @attributes[:tags]
        @attributes.delete :tags
      end
    end

    def attributes
      @attributes
    end

    def show_from
      @attributes['show_from']
    end

    def due
      @attributes['due']
    end

    def project_name
      @params['project_name'].strip unless @params['project_name'].nil?
    end

    def project_id
      @attributes['project_id']
    end

    def context_name
      @params['context_name'].strip unless @params['context_name'].nil?
    end

    def context_id
      @attributes['context_id']
    end

    def tag_list
      @params['tag_list']
    end

    def predecessor_list
      @params['predecessor_list']
    end

    def parse_dates()
      @attributes['show_from'] = @prefs.parse_date(show_from)
      @attributes['due'] = @prefs.parse_date(due)
      @attributes['due'] ||= ''
    end

    def project_specified_by_name?
      return false unless @attributes['project_id'].blank?
      return false if project_name.blank?
      return false if project_name == 'None'
      true
    end

    def context_specified_by_name?
      return false unless @attributes['context_id'].blank?
      return false if context_name.blank?
      true
    end

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
