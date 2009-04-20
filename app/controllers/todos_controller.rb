class TodosController < ApplicationController

  helper :todos

  skip_before_filter :login_required, :only => [:index, :calendar]
  prepend_before_filter :login_or_feed_token_required, :only => [:index, :calendar]
  append_before_filter :init, :except => [ :destroy, :completed, :completed_archive, :check_deferred, :toggle_check, :toggle_star, :edit, :update, :create, :calendar ]
  append_before_filter :get_todo_from_params, :only => [ :edit, :toggle_check, :toggle_star, :show, :update, :destroy ]

  session :off, :only => :index, :if => Proc.new { |req| is_feed_request(req) }

  def index
    current_user.deferred_todos.find_and_activate_ready
    @projects = current_user.projects.find(:all, :include => [:default_context])
    @contexts = current_user.contexts.find(:all)

    @contexts_to_show = current_user.contexts.active
    
    respond_to do |format|
      format.html  &render_todos_html
      format.m     &render_todos_mobile
      format.xml   { render :xml => @todos.to_xml( :except => :user_id ) }
      format.rss   &render_rss_feed
      format.atom  &render_atom_feed
      format.text  &render_text_feed
      format.ics   &render_ical_feed
    end
  end
  
  def new
    @projects = current_user.projects.active
    @contexts = current_user.contexts.find(:all)
    respond_to do |format|
      format.m {
        @new_mobile = true
        @return_path=cookies[:mobile_url]
        @mobile_from_context = current_user.contexts.find_by_id(params[:from_context]) if params[:from_context]
        @mobile_from_project = current_user.projects.find_by_id(params[:from_project]) if params[:from_project]
        if params[:from_project] && !params[:from_context]
          # we have a project but not a context -> use the default context
          @mobile_from_context = @mobile_from_project.default_context
        end
        render :action => "new" 
      }
    end
  end
  
  def create
    @source_view = params['_source_view'] || 'todo'
    p = TodoCreateParamsHelper.new(params, prefs)        
    p.parse_dates() unless mobile?
    tag_list = p.tag_list
    
    @todo = current_user.todos.build(p.attributes)
    
    if p.project_specified_by_name?
      project = current_user.projects.find_or_create_by_name(p.project_name)
      @new_project_created = project.new_record_before_save?
      @todo.project_id = project.id
      if tag_list.blank?
        tag_list = project.default_tags unless project.default_tags.blank?
      else
        tag_list += ','+project.default_tags unless project.default_tags.blank?
      end
    end
    
    if p.context_specified_by_name?
      context = current_user.contexts.find_or_create_by_name(p.context_name)
      @new_context_created = context.new_record_before_save?
      @not_done_todos = [@todo] if @new_context_created
      @todo.context_id = context.id
    end

    @todo.update_state_from_project
    @saved = @todo.save
    unless (@saved == false) || tag_list.blank?
      @todo.tag_with(tag_list)
      @todo.tags.reload
    end
    
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.m do
        @return_path=cookies[:mobile_url]
        # todo: use function for this fixed path
        @return_path='/m' if @return_path.nil?
        if @saved
          redirect_to @return_path
        else
          @projects = current_user.projects.find(:all)
          @contexts = current_user.contexts.find(:all)
          render :action => "new"
        end
      end
      format.js do
        determine_down_count if @saved
        @contexts = current_user.contexts.find(:all) if @new_context_created
        @projects = current_user.projects.find(:all) if @new_project_created
        @initial_context_name = params['default_context_name']
        @initial_project_name = params['default_project_name']
        render :action => 'create'
      end
      format.xml do
        if @saved
          head :created, :location => todo_url(@todo)
        else
          render :xml => @todo.errors.to_xml, :status => 422
        end
      end
    end
  end
  
  def edit
    @projects = current_user.projects.find(:all)
    @contexts = current_user.contexts.find(:all)
    @source_view = params['_source_view'] || 'todo'
    @tag_name = params['_tag_name']
    respond_to do |format|
      format.js
    end
  end
  
  def show
    respond_to do |format|
      format.m do
        @projects = current_user.projects.active
        @contexts = current_user.contexts.find(:all)
        @edit_mobile = true
        @return_path=cookies[:mobile_url]
        render :action => 'show'
      end
      format.xml { render :xml => @todo.to_xml( :root => 'todo', :except => :user_id ) }
    end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    @source_view = params['_source_view'] || 'todo'
    @original_item_due = @todo.due
    @original_item_was_deferred = @todo.deferred?
    @saved = @todo.toggle_completion!
  
    # check if this todo has a related recurring_todo. If so, create next todo
    @new_recurring_todo = check_for_next_todo(@todo) if @saved
    
    respond_to do |format|
      format.js do
        if @saved
          determine_remaining_in_context_count(@todo.context_id)
          determine_down_count
          determine_completed_count if @todo.completed?
          determine_deferred_tag_count(params['_tag_name']) if @source_view == 'tag'
          if source_view_is :calendar
            @original_item_due_id = get_due_id_for_calendar(@original_item_due)
            @old_due_empty = is_old_due_empty(@original_item_due_id)
          end
        end
        render
      end
      format.xml { render :xml => @todo.to_xml( :except => :user_id ) }
      format.html do
        if @saved
          # TODO: I think this will work, but can't figure out how to test it
          notify :notice, "The action <strong>'#{@todo.description}'</strong> was marked as <strong>#{@todo.completed? ? 'complete' : 'incomplete' }</strong>"
          redirect_to :action => "index"
        else
          notify :notice, "The action <strong>'#{@todo.description}'</strong> was NOT marked as <strong>#{@todo.completed? ? 'complete' : 'incomplete' } due to an error on the server.</strong>", "index"
          redirect_to :action =>  "index"
        end
      end
    end
  end
  
  def toggle_star
    @todo.toggle_star!
    @saved = @todo.save!
    respond_to do |format|
      format.js
      format.xml { render :xml => @todo.to_xml( :except => :user_id ) }
    end
  end

  def update
    @source_view = params['_source_view'] || 'todo'
    init_data_for_sidebar unless mobile?
    if params[:tag_list]
      @todo.tag_with(params[:tag_list])
      @todo.tags(true) #force a reload for proper rendering
    end
    @original_item_context_id = @todo.context_id
    @original_item_project_id = @todo.project_id
    @original_item_was_deferred = @todo.deferred?
    @original_item_due = @todo.due
    @original_item_due_id = get_due_id_for_calendar(@todo.due) 
    
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
    end
    
    if params['todo']['context_id'].blank? && !params['context_name'].blank?
      context = current_user.contexts.find_by_name(params['context_name'].strip)
      unless context
        context = current_user.contexts.build
        context.name = params['context_name'].strip
        context.save
        @new_context_created = true
        @not_done_todos = [@todo]
      end
      params["todo"]["context_id"] = context.id
    end
    
    if params["todo"].has_key?("due")
      params["todo"]["due"] = parse_date_per_user_prefs(params["todo"]["due"])
    else
      params["todo"]["due"] = ""
    end
    
    if params['todo']['show_from']
      params['todo']['show_from'] = parse_date_per_user_prefs(params['todo']['show_from'])
    end
    
    if params['done'] == '1' && !@todo.completed?
      @todo.complete!
    end
    # strange. if checkbox is not checked, there is no 'done' in params.
    # Therefore I've used the negation
    if !(params['done'] == '1') && @todo.completed?
      @todo.activate!
    end
    
    @todo.attributes = params["todo"]
    @saved = @todo.save

    @context_changed = @original_item_context_id != @todo.context_id
    @todo_was_activated_from_deferred_state = @original_item_was_deferred && @todo.active?
    
    if source_view_is :calendar
      @due_date_changed = @original_item_due != @todo.due
      if @due_date_changed
        @old_due_empty = is_old_due_empty(@original_item_due_id)
        if @todo.due.nil?
          # do not act further on date change when date is changed to nil
          @due_date_changed = false
        else
          @new_due_id = get_due_id_for_calendar(@todo.due)
        end
      end
    end
    
    if @context_changed
      determine_remaining_in_context_count(@original_item_context_id)
    else
      determine_remaining_in_context_count(@todo.context_id)
    end
    
    @project_changed = @original_item_project_id != @todo.project_id
    if (@project_changed && !@original_item_project_id.nil?) then
      @todo.update_state_from_project
      @todo.save!
      @remaining_undone_in_project = current_user.projects.find(@original_item_project_id).not_done_todos.count
    end
    determine_down_count
    determine_deferred_tag_count(params['_tag_name']) if @source_view == 'tag'

    respond_to do |format|
      format.js
      format.xml { render :xml => @todo.to_xml( :except => :user_id ) }
      format.m do
        if @saved
          if cookies[:mobile_url]
            cookies[:mobile_url] = {:value => nil, :secure => SITE_CONFIG['secure_cookies']}
            redirect_to cookies[:mobile_url]
          else
            redirect_to formatted_todos_path(:m)
          end
        else
          render :action => "edit", :format => :m
        end
      end
    end
  end
    
  def destroy
    @todo = get_todo_from_params
    @original_item_due = @todo.due
    @context_id = @todo.context_id
    @project_id = @todo.project_id
   
    @saved = @todo.destroy

    # check if this todo has a related recurring_todo. If so, create next todo
    @new_recurring_todo = check_for_next_todo(@todo) if @saved
    
    respond_to do |format|
      
      format.html do
        if @saved
          notify :notice, "Successfully deleted next action", 2.0
          redirect_to :action => 'index'
        else
          notify :error, "Failed to delete the action", 2.0
          redirect_to :action => 'index'
        end
      end  
      
      format.js do
        if @saved
          determine_down_count
          if source_view_is_one_of(:todo, :deferred)
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

  def completed
    @page_title = "TRACKS::Completed tasks"
    @done = current_user.completed_todos
    @done_today = @done.completed_within Time.zone.now - 1.day
    @done_this_week = @done.completed_within Time.zone.now - 1.week
    @done_this_month = @done.completed_within Time.zone.now - 4.week
    @count = @done_today.size + @done_this_week.size + @done_this_month.size
  end

  def completed_archive
    @page_title = "TRACKS::Archived completed tasks"
    @done = current_user.completed_todos
    @count = @done.size
    @done_archive = @done.completed_more_than Time.zone.now - 28.days
  end
  
  def list_deferred
    @source_view = 'deferred'
    @page_title = "TRACKS::Tickler"
    
    @projects = current_user.projects.find(:all, :include => [ :todos, :default_context ])
    @contexts_to_show = @contexts = current_user.contexts.find(:all, :include => [ :todos ])
    
    current_user.deferred_todos.find_and_activate_ready
    @not_done_todos = current_user.deferred_todos
    @count = @not_done_todos.size
    @down_count = @count
    @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json unless mobile?
    
    respond_to do |format|
      format.html
      format.m { render :action => 'mobile_list_deferred' }
    end
  end
  
  # Check for any due tickler items, activate them Called by
  # periodically_call_remote
  def check_deferred
    @due_tickles = current_user.deferred_todos.find_and_activate_ready
    respond_to do |format|
      format.html { redirect_to home_path }
      format.js
    end
  end
  
  def filter_to_context
    context = current_user.contexts.find(params['context']['id'])
    redirect_to formatted_context_todos_path(context, :m)
  end
  
  def filter_to_project
    project = current_user.projects.find(params['project']['id'])
    redirect_to formatted_project_todos_path(project, :m)
  end
  
  # /todos/tag/[tag_name] shows all the actions tagged with tag_name
  def tag
    @source_view = params['_source_view'] || 'tag'
    @tag_name = params[:name]
    @page_title = "TRACKS::Tagged with \'#{@tag_name}\'"
    
    # mobile tags are routed with :name ending on .m. So we need to chomp it
    @tag_name = @tag_name.chomp('.m') if mobile?
    
    @tag = Tag.find_by_name(@tag_name)
    @tag = Tag.new(:name => @tag_name) if @tag.nil?
    tag_collection = @tag.todos
    
    @not_done_todos = tag_collection.find(:all, 
      :conditions => ['todos.user_id = ? and state = ?', current_user.id, 'active'],
      :order => 'todos.due IS NULL, todos.due ASC, todos.created_at ASC')
    @hidden_todos = current_user.todos.find(:all, 
      :include => [:taggings, :tags, :context], 
      :conditions => ['tags.name = ? AND (todos.state = ? OR (contexts.hide = ? AND todos.state = ?))', @tag_name, 'project_hidden', true, 'active'],
      :order => 'todos.completed_at DESC, todos.created_at DESC')
    @deferred = tag_collection.find(:all, 
      :conditions => ['todos.user_id = ? and state = ?', current_user.id, 'deferred'],
      :order => 'show_from ASC, todos.created_at DESC')
    
    # If you've set no_completed to zero, the completed items box isn't shown on
    # the tag page
    max_completed = current_user.prefs.show_number_completed
    @done = tag_collection.find(:all, 
      :limit => max_completed, 
      :conditions => ['todos.user_id = ? and state = ?', current_user.id, 'completed'],
      :order => 'todos.completed_at DESC')

    @projects = current_user.projects
    @contexts = current_user.contexts
    @contexts_to_show = @contexts.reject {|x| x.hide? }
    
    # Set count badge to number of items with this tag
    @not_done_todos.empty? ? @count = 0 : @count = @not_done_todos.size
    @down_count = @count 

    respond_to do |format|
      format.html {
        @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json
      }
      format.m { 
        cookies[:mobile_url]= {:value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
        render :action => "mobile_tag"         
      }
    end
  end
  
  def defer
    @source_view = params['_source_view'] || 'todo'
    numdays = params['days'].to_i
    @todo = Todo.find(params[:id])
    @original_item_context_id = @todo.context_id
    @todo.show_from = (@todo.show_from || @todo.user.date) + numdays.days
    @saved = @todo.save

    determine_down_count
    determine_remaining_in_context_count(@todo.context_id)
    if @source_view == 'project'
      @remaining_undone_in_project = current_user.projects.find(@todo.project_id).not_done_todos.count
      @original_item_project_id = @todo.project_id
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js {render :action => 'update'}
    end
  end

  def calendar
    @source_view = params['_source_view'] || 'calendar'
    @page_title = "TRACKS::Calendar"

    @projects = current_user.projects.find(:all)
    @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json
  
    due_today_date = Time.zone.now
    due_this_week_date = Time.zone.now.end_of_week
    due_next_week_date = due_this_week_date + 7.days
    due_this_month_date = Time.zone.now.end_of_month
    
    @due_today = current_user.todos.not_completed.find(:all,
      :include => [:taggings, :tags], 
      :conditions => ['todos.due <= ?', due_today_date],
      :order => "due")
    @due_this_week = current_user.todos.not_completed.find(:all,
      :include => [:taggings, :tags], 
      :conditions => ['todos.due > ? AND todos.due <= ?', due_today_date, due_this_week_date],
      :order => "due")
    @due_next_week = current_user.todos.not_completed.find(:all,
      :include => [:taggings, :tags], 
      :conditions => ['todos.due > ? AND todos.due <= ?', due_this_week_date, due_next_week_date],
      :order => "due")
    @due_this_month = current_user.todos.not_completed.find(:all,
      :include => [:taggings, :tags], 
      :conditions => ['todos.due > ? AND todos.due <= ?', due_next_week_date, due_this_month_date],
      :order => "due")
    @due_after_this_month = current_user.todos.not_completed.find(:all,
      :include => [:taggings, :tags], 
      :conditions => ['todos.due > ?', due_this_month_date],
      :order => "due")

    @count = current_user.todos.not_completed.are_due.count

    respond_to do |format|
      format.html
      format.ics   {
        @due_all = current_user.todos.not_completed.are_due.find(:all, :order => "due")
        render :action => 'calendar', :layout => false, :content_type => Mime::ICS
      }
    end
  end  
  
  private
  
  def get_todo_from_params
    @todo = current_user.todos.find(params['id'])
  end

  def init
    @source_view = params['_source_view'] || 'todo'
    init_data_for_sidebar unless mobile?
    init_todos      
  end

  def with_feed_query_scope(&block)
    unless TodosController.is_feed_request(request)
      Todo.send(:with_scope, :find => {:conditions => ['todos.state = ?', 'active']}) do
        yield
        return
      end
    end
    condition_builder = FindConditionBuilder.new

    if params.key?('done')
      condition_builder.add 'todos.state = ?', 'completed'
    else
      condition_builder.add 'todos.state = ?', 'active'
    end

    @title = "Tracks - Next Actions"
    @description = "Filter: "

    if params.key?('due')
      due_within = params['due'].to_i
      due_within_when = Time.zone.now + due_within.days
      condition_builder.add('todos.due <= ?', due_within_when)
      due_within_date_s = due_within_when.strftime("%Y-%m-%d")
      @title << " due today" if (due_within == 0)
      @title << " due within a week" if (due_within == 6)
      @description << " with a due date #{due_within_date_s} or earlier"
    end

    if params.key?('done')
      done_in_last = params['done'].to_i
      condition_builder.add('todos.completed_at >= ?', Time.zone.now - done_in_last.days)
      @title << " actions completed"
      @description << " in the last #{done_in_last.to_s} days"
    end
    
    if params.key?('tag')
      tag = Tag.find_by_name(params['tag'])
      if tag.nil?
        tag = Tag.new(:name => params['tag'])
      end
      condition_builder.add('taggings.tag_id = ?', tag.id)
    end
      
    Todo.send :with_scope, :find => {:conditions => condition_builder.to_conditions} do
      yield
    end
      
  end

  def with_parent_resource_scope(&block)
    @feed_title = "Actions "
    if (params[:context_id])
      @context = current_user.contexts.find_by_params(params)
      @feed_title = @feed_title + "in context '#{@context.name}'"
      Todo.send :with_scope, :find => {:conditions => ['todos.context_id = ?', @context.id]} do
        yield
      end
    elsif (params[:project_id])
      @project = current_user.projects.find_by_params(params)
      @feed_title = @feed_title + "in project '#{@project.name}'"
      @project_feed = true
      Todo.send :with_scope, :find => {:conditions => ['todos.project_id = ?', @project.id]} do
        yield
      end
    else
      yield
    end      
  end

  def with_limit_scope(&block)
    if params.key?('limit')
      Todo.send :with_scope, :find => { :limit => params['limit'] } do
        yield
      end
      if TodosController.is_feed_request(request) && @description
        if params.key?('limit')
          @description << "Lists the last #{params['limit']} incomplete next actions"
        else
          @description << "Lists incomplete next actions"
        end
      end
    else
      yield
    end
  end

  def init_todos
    with_feed_query_scope do
      with_parent_resource_scope do # @context or @project may get defined here
        with_limit_scope do
            
          if mobile?
            init_todos_for_mobile_view              
          else
            
            # Note: these next two finds were previously using
            # current_users.todos.find but that broke with_scope for :limit

            # Exclude hidden projects from count on home page
            @todos = Todo.find(:all, :conditions => ['todos.user_id = ?', current_user.id], :include => [ :project, :context, :tags ])

            # Exclude hidden projects from the home page
            @not_done_todos = Todo.find(:all, 
              :conditions => ['todos.user_id = ? AND contexts.hide = ? AND (projects.state = ? OR todos.project_id IS NULL)', 
                current_user.id, false, 'active'], 
              :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC", 
              :include => [ :project, :context, :tags ])
          end

        end
      end
    end
  end
    
  def init_todos_for_mobile_view
    # Note: these next two finds were previously using current_users.todos.find
    # but that broke with_scope for :limit
    
    # Exclude hidden projects from the home page
    @not_done_todos = Todo.find(:all, 
      :conditions => ['todos.user_id = ? AND todos.state = ? AND contexts.hide = ? AND (projects.state = ? OR todos.project_id IS NULL)', 
        current_user.id, 'active', false, 'active'], 
      :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC", 
      :include => [ :project, :context, :tags ])
  end
    
  def determine_down_count
    source_view do |from|
      from.todo do
        @down_count = Todo.count(
          :all, 
          :conditions => ['todos.user_id = ? and todos.state = ? and contexts.hide = ? AND (projects.state = ? OR todos.project_id IS NULL)', current_user.id, 'active', false, 'active'], 
          :include => [ :project, :context ])
        # #@down_count = Todo.count_by_sql(['SELECT COUNT(*) FROM todos,
        # contexts WHERE todos.context_id = contexts.id and todos.user_id = ?
        # and todos.state = ? and contexts.hide = ?', current_user.id, 'active',
        # false])
      end
      from.context do
        @down_count = current_user.contexts.find(@todo.context_id).not_done_todo_count
      end
      from.project do
        unless @todo.project_id == nil
          @down_count = current_user.projects.find(@todo.project_id).not_done_todos_including_hidden.count
          @deferred_count = current_user.projects.find(@todo.project_id).deferred_todos.count
        end
      end
      from.deferred do
        @down_count = current_user.todos.count_in_state(:deferred)
      end
      from.tag do
        @tag_name = params['_tag_name']
        @tag = Tag.find_by_name(@tag_name)
        if @tag.nil?
          @tag = Tag.new(:name => @tag_name)
        end
        tag_collection = @tag.todos
        @not_done_todos = tag_collection.find(:all, :conditions => ['todos.user_id = ? and state = ?', current_user.id, 'active'])
        @not_done_todos.empty? ? @down_count = 0 : @down_count = @not_done_todos.size
      end
    end
  end 
    
  def determine_remaining_in_context_count(context_id = @todo.context_id)
    source_view do |from|
      from.deferred { @remaining_in_context = current_user.contexts.find(context_id).deferred_todo_count }
      from.tag      { 
        tag = Tag.find_by_name(params['_tag_name'])
        if tag.nil?
          tag = Tag.new(:name => params['tag'])
        end
        @remaining_in_context = current_user.contexts.find(context_id).not_done_todo_count({:tag => tag.id})
      }
    end
    @remaining_in_context = current_user.contexts.find(context_id).not_done_todo_count if @remaining_in_context.nil?
  end 
    
  def determine_completed_count
    source_view do |from|
      from.todo do
        @completed_count = Todo.count_by_sql(['SELECT COUNT(*) FROM todos, contexts WHERE todos.context_id = contexts.id and todos.user_id = ? and todos.state = ? and contexts.hide = ?', current_user.id, 'completed', false])
      end
      from.context do
        @completed_count = current_user.contexts.find(@todo.context_id).done_todo_count
      end
      from.project do
        unless @todo.project_id == nil
          @completed_count = current_user.projects.find(@todo.project_id).done_todos.count
        end
      end
    end
  end

  def determine_deferred_tag_count(tag)
    tag_collection = Tag.find_by_name(tag).todos
    @deferred_tag_count = tag_collection.count(:all,
      :conditions => ['todos.user_id = ? and state = ?', current_user.id, 'deferred'],
      :order => 'show_from ASC, todos.created_at DESC')
  end

  def render_todos_html
    lambda do
      @page_title = "TRACKS::List tasks"

      # If you've set no_completed to zero, the completed items box isn't shown
      # on the home page
      max_completed = current_user.prefs.show_number_completed
      @done = current_user.completed_todos.find(:all, :limit => max_completed, :include => [ :context, :project, :tags ]) unless max_completed == 0

      # Set count badge to number of not-done, not hidden context items
      @count = 0
      @todos.each do |x|
        if x.active?
          if x.project.nil?
            @count += 1 if !x.context.hide?
          else
            @count += 1 if x.project.active?  && !x.context.hide?
          end
        end
      end
       
      @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json
       
      render
    end
  end

  def render_todos_mobile
    lambda do
      @page_title = "All actions"
      @home = true
      cookies[:mobile_url]= { :value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
      determine_down_count
    
      render :action => 'index'
    end
  end
    
  def render_rss_feed
    lambda do
      render_rss_feed_for @todos, :feed => todo_feed_options,
        :item => {
        :title => :description,
        :link => lambda { |t| @project_feed.nil? ? context_url(t.context) : project_url(t.project) },
        :guid => lambda { |t| todo_url(t) },
        :description => todo_feed_content
      }
    end
  end
    
  def todo_feed_options
    options = Todo.feed_options(current_user)
    options[:title] = @feed_title
    return options
  end

  def todo_feed_content
    lambda do |i|
      item_notes = sanitize(markdown( i.notes )) if i.notes?
      due = "<div>Due: #{format_date(i.due)}</div>\n" if i.due?
      done = "<div>Completed: #{format_date(i.completed_at)}</div>\n" if i.completed?
      context_link = "<a href=\"#{ context_url(i.context) }\">#{ i.context.name }</a>"
      if i.project_id?
        project_link = "<a href=\"#{ project_url(i.project) }\">#{ i.project.name }</a>"
      else
        project_link = "<em>none</em>"
      end
      "#{done||''}#{due||''}#{item_notes||''}\n<div>Project:  #{project_link}</div>\n<div>Context:  #{context_link}</div>"
    end
  end

  def render_atom_feed
    lambda do
      render_atom_feed_for @todos, :feed => todo_feed_options,
        :item => {
        :title => :description,
        :link => lambda { |t| context_url(t.context) },
        :description => todo_feed_content,
        :author => lambda { |p| nil }
      }
    end
  end

  def render_text_feed
    lambda do
      render :action => 'index', :layout => false, :content_type => Mime::TEXT
    end
  end

  def render_ical_feed
    lambda do
      render :action => 'index', :layout => false, :content_type => Mime::ICS
    end
  end

  def self.is_feed_request(req)
    ['rss','atom','txt','ics'].include?(req.parameters[:format])
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
    due_today_date = Time.zone.now
    due_this_week_date = Time.zone.now.end_of_week
    due_next_week_date = due_this_week_date + 7.days
    due_this_month_date = Time.zone.now.end_of_month
    case id
    when "due_today"
      return 0 == current_user.todos.not_completed.count(:all,
        :conditions => ['todos.due <= ?', due_today_date])
    when "due_this_week"
      return 0 == current_user.todos.not_completed.count(:all,
        :conditions => ['todos.due > ? AND todos.due <= ?', due_today_date, due_this_week_date])
    when "due_next_week"
      return 0 == current_user.todos.not_completed.count(:all,
        :conditions => ['todos.due > ? AND todos.due <= ?', due_this_week_date, due_next_week_date])
    when "due_this_month"
      return 0 == current_user.todos.not_completed.count(:all,
        :conditions => ['todos.due > ? AND todos.due <= ?', due_next_week_date, due_this_month_date])
    when "due_after_this_month"      
      return 0 == current_user.todos.not_completed.count(:all,
        :conditions => ['todos.due > ?', due_this_month_date])
    else
      raise Exception.new, "unknown due id for calendar: '#{id}'"      
    end
  end

  class FindConditionBuilder

    def initialize
      @queries = Array.new
      @params = Array.new
    end

    def add(query, param)
      @queries << query
      @params << param
    end

    def to_conditions
      [@queries.join(' AND ')] + @params
    end
  end

  class TodoCreateParamsHelper

    def initialize(params, prefs)
      @params = params['request'] || params
      @prefs = prefs
      @attributes = params['request'] && params['request']['todo']  || params['todo']
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
      
    def context_name
      @params['context_name'].strip unless @params['context_name'].nil?
    end
      
    def tag_list
      @params['tag_list']
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
end
