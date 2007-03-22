class TodosController < ApplicationController

  helper :todos

  append_before_filter :init, :except => [ :destroy, :completed, :completed_archive, :check_deferred ]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]
  session :off, :only => :index, :if => Proc.new { |req| is_feed_request(req) }

  layout 'standard'

  def index
    @projects = @user.projects.find(:all, :include => [ :todos ])
    @contexts = @user.contexts.find(:all, :include => [ :todos ])

    @contexts_to_show = @contexts.reject {|x| x.hide? }

    respond_to do |format|
      format.html &render_todos_html
      format.xml { render :action => 'list.rxml', :layout => false }
      format.rss   &render_rss_feed
      format.atom  &render_atom_feed
      format.text  &render_text_feed
      format.ics   &render_ical_feed
    end
  end

  def create
    @todo = @user.todos.build
    p = params['request'] || params
    
    if p['todo']['show_from']
      p['todo']['show_from'] = parse_date_per_user_prefs(p['todo']['show_from'])
    end
    
    @todo.attributes = p['todo']
    
    if p['todo']['project_id'].blank? && !p['project_name'].blank? && p['project_name'] != 'None'
      project = @user.projects.find_by_name(p['project_name'].strip)
      unless project
          project = @user.projects.build
          project.name = p['project_name'].strip
          project.save
          @new_project_created = true
      end
      @todo.project_id = project.id
    end
    
    if p['todo']['context_id'].blank? && !p['context_name'].blank?
      context = @user.contexts.find_by_name(p['context_name'].strip)
      unless context
          context = @user.contexts.build
          context.name = p['context_name'].strip
          context.save
          @new_context_created = true
          @not_done_todos = [@todo]
      end
      @todo.context_id = context.id
    end

    if @todo.due?
      @todo.due = parse_date_per_user_prefs(p['todo']['due'])
    else
      @todo.due = ""
    end
    
    @saved = @todo.save
    if @saved
      @todo.tag_with(params[:tag_list],@user)
      @todo.reload
    end
    
    respond_to do |wants|
      wants.html { redirect_to :action => "index" }
      wants.js do
        if @saved
          determine_down_count
        end
        render :action => 'create'
      end
      wants.xml { render :xml => @todo.to_xml( :root => 'todo', :except => :user_id ) }
    end
  end
  
  def edit
    @todo = check_user_return_todo
  end
  
  def show
    item = check_user_return_todo
    respond_to do |wants|
       wants.xml { render :xml => item.to_xml( :root => 'todo', :except => :user_id ) }
     end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    @todo = check_user_return_todo
    @todo.toggle_completion!
    @saved = @todo.save
    respond_to do |format|
      format.js do
        if @saved
          @remaining_undone_in_context = @user.contexts.find(@todo.context_id).not_done_todo_count
          determine_down_count
          determine_completed_count
        end
        render
      end
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

  def update
    @todo = check_user_return_todo
    @todo.tag_with(params[:tag_list],@user)
    @original_item_context_id = @todo.context_id
    @original_item_project_id = @todo.project_id
    @original_item_was_deferred = @todo.deferred?
    if params['todo']['project_id'].blank? && !params['project_name'].blank?
      if params['project_name'] == 'None'
        project = Project.null_object
      else
        project = @user.projects.find_by_name(params['project_name'].strip)
        unless project
          project = @user.projects.build
          project.name = params['project_name'].strip
          project.save
          @new_project_created = true
        end
      end
      params["todo"]["project_id"] = project.id
    end
    
    if params['todo']['context_id'].blank? && !params['context_name'].blank?
      context = @user.contexts.find_by_name(params['context_name'].strip)
      unless context
          context = @user.contexts.build
          context.name = params['context_name'].strip
          context.save
          @new_context_created = true
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
    
    @saved = @todo.update_attributes params["todo"]
    @context_changed = @original_item_context_id != @todo.context_id
    @todo_was_activated_from_deferred_state = @original_item_was_deferred && @todo.active?
    if @context_changed then @remaining_undone_in_context = @user.contexts.find(@original_item_context_id).not_done_todo_count; end
    @project_changed = @original_item_project_id != @todo.project_id
    if (@project_changed && !@original_item_project_id.nil?) then @remaining_undone_in_project = @user.projects.find(@original_item_project_id).not_done_todo_count; end
    determine_down_count
  end
    
  def destroy
    @todo = check_user_return_todo
    @context_id = @todo.context_id
    @project_id = @todo.project_id
    @saved = @todo.destroy
    
    respond_to do |wants|
      
      wants.html do
        if @saved
          notify :notice, "Successfully deleted next action", 2.0
          redirect_to :action => 'index'
        else
          notify :error, "Failed to delete the action", 2.0
          redirect_to :action => 'index'
        end
      end
      
      wants.js do
        if @saved
          determine_down_count
          source_view do |from|
             from.todo do
               @remaining_undone_in_context = @user.contexts.find(@context_id).not_done_todo_count
             end
           end
        end
        render
      end
      
      wants.xml { render :text => '200 OK. Action deleted.', :status => 200 }
    
    end
  end

  def completed
    @page_title = "TRACKS::Completed tasks"
    @done = @user.completed_todos
    @done_today = @done.completed_within @user.time - 1.day
    @done_this_week = @done.completed_within @user.time - 1.week
    @done_this_month = @done.completed_within @user.time - 4.week
  end

  def completed_archive
    @page_title = "TRACKS::Archived completed tasks"
    @done = @user.completed_todos
    @done_archive = @done.completed_more_than @user.time - 28.days
  end
  
  def list_deferred
    @source_view = 'deferred'
    @page_title = "TRACKS::Tickler"
    @tickles = @user.deferred_todos
    @count = @tickles.size
    @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json
  end
  
  # Check for any due tickler items, activate them
  # Called by periodically_call_remote
  def check_deferred
    @due_tickles = @user.deferred_todos.find_and_activate_ready
    respond_to do |format|
      format.html { redirect_to home_path }
      format.js
    end
  end
  
  # /todos/tag/[tag_name] shows all the actions tagged with tag_name
  #
  def tag
    
    @tag = tag_name = params[:name]
    
    if Tag.find_by_name(tag_name).nil?
      # TODO: This doesn't work - you get kicked back to the index
      # with a generic "Error occured on the server error"
      notify :error, "Tag \'#{@tag}\' does not exist", 2.0
      @not_done_todos = []
    else 
      tag_collection = Tag.find_by_name(tag_name).todos
      @not_done_todos = tag_collection.find(:all, :conditions => ['taggings.user_id = ? and state = ?', @user.id, 'active'])
    end
    
    @contexts = @user.contexts.find(:all, :include => [ :todos ])
    @contexts_to_show = @contexts.reject {|x| x.hide? }

    @page_title = "TRACKS::Tagged with \'#{@tag}\'"
    # If you've set no_completed to zero, the completed items box
    # isn't shown on the home page
    max_completed = @user.prefs.show_number_completed
    @done = @user.completed_todos.find(:all, :limit => max_completed, :include => [ :context, :project, :tags ]) unless max_completed == 0
    # Set count badge to number of items with this tag
    @not_done_todos.empty? ? @count = 0 : @count = @not_done_todos.size
    @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json

  end
  
  private

    def check_user_return_todo
      todo = Todo.find( params['id'].to_i )
      if @user == todo.user
        return todo
      else
        @error_message = 'Item and session user mis-match: #{todo.user.name} and #{@todo.name}!'
        respond_to do |wants|
          wants.html do
            notify :error, @error_message, 8.0
            render :action => "index"
          end
          wants.js { render :action => 'error' }
          wants.xml { render :text => @error_message, :status => 403 }
        end
      end
    end

    def init
      @source_view = params['_source_view'] || 'todo'
      init_data_for_sidebar
      init_todos      
    end

    def with_feed_query_scope(&block)
      unless TodosController.is_feed_request(request)
        yield
        return
      end

      condition_builder = FindConditionBuilder.new
      options = Hash.new

      if params.key?('done')
        condition_builder.add 'todos.state = ?', 'completed'
      else
        condition_builder.add 'todos.state = ?', 'active'
      end

      @title = "Tracks - Next Actions"
      @description = "Filter: "

      if params.key?('due')
        due_within = params['due'].to_i
        due_within_when = @user.time + due_within.days
        condition_builder.add('todos.due <= ?', due_within_when)
        due_within_date_s = due_within_when.strftime("%Y-%m-%d")
        @title << " due today" if (due_within == 0)
        @title << " due within a week" if (due_within == 6)
        @description << " with a due date #{due_within_date_s} or earlier"
      end

      if params.key?('done')
        done_in_last = params['done'].to_i
        condition_builder.add('todos.completed_at >= ?', @user.time - done_in_last.days)
        @title << " actions completed"
        @description << " in the last #{done_in_last.to_s} days"
      end

      Todo.with_scope :find => {:conditions => condition_builder.to_conditions} do
        yield
      end
      
    end

    def with_parent_resource_scope(&block)
      if (params[:context_id])
        context = @user.contexts.find_by_params(params)
        Todo.with_scope :find => {:conditions => ['todos.context_id = ?', context.id]} do
          yield
        end
      elsif (params[:project_id])
        project = @user.projects.find_by_params(params)
        Todo.with_scope :find => {:conditions => ['todos.project_id = ?', project.id]} do
          yield
        end
      else
        yield
      end      
    end

    def with_limit_scope(&block)
      if params.key?('limit')
        Todo.with_scope :find => {:limit => params['limit']} do
          yield
        end
        #@description = limit ? "Lists the last #{limit} incomplete next actions" : "Lists incomplete next actions"
      else
        yield
      end
    end

    def init_todos
      with_feed_query_scope do
        with_parent_resource_scope do
          with_limit_scope do

            # Exclude hidden projects from count on home page
            @todos = @user.todos.find(:all, :conditions => ['todos.state = ? or todos.state = ?', 'active', 'complete'], :include => [ :project, :context, :tags ])

            # Exclude hidden projects from the home page
            @not_done_todos = @user.todos.find(:all, :conditions => ['todos.state = ?', 'active'], :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC", :include => [ :project, :context, :tags ])

          end
        end
      end
    end
    
    def determine_down_count
      source_view do |from|
         from.todo do
           @down_count = Todo.count_by_sql(['SELECT COUNT(*) FROM todos, contexts WHERE todos.context_id = contexts.id and todos.user_id = ? and todos.state = ? and contexts.hide = ?', @user.id, 'active', false])
         end
         from.context do
           @down_count = @user.contexts.find(@todo.context_id).not_done_todo_count
         end
         from.project do
           unless @todo.project_id == nil
             @down_count = @user.projects.find(@todo.project_id).not_done_todo_count
             @deferred_count = @user.projects.find(@todo.project_id).deferred_todo_count
           end
         end
         from.deferred do
           @down_count = @user.todos.count_in_state(:deferred)
         end
      end
    end 
    
    def determine_completed_count
      source_view do |from|
         from.todo do
           @completed_count = Todo.count_by_sql(['SELECT COUNT(*) FROM todos, contexts WHERE todos.context_id = contexts.id and todos.user_id = ? and todos.state = ? and contexts.hide = ?', @user.id, 'completed', false])
         end
         from.context do
           @completed_count = @user.contexts.find(@todo.context_id).done_todo_count
         end
         from.project do
           unless @todo.project_id == nil
             @completed_count = @user.projects.find(@todo.project_id).done_todo_count
           end
         end
      end
    end

    def render_todos_html
     lambda do
       @page_title = "TRACKS::List tasks"

       # If you've set no_completed to zero, the completed items box
       # isn't shown on the home page
       max_completed = @user.prefs.show_number_completed
       @done = @user.completed_todos.find(:all, :limit => max_completed, :include => [ :context, :project, :tags ]) unless max_completed == 0

       # Set count badge to number of not-done, not hidden context items
       @count = @todos.reject { |x| !x.active? || x.context.hide? }.size
       
       @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json
       
       render
      end
    end
    
    def render_rss_feed
      lambda do
        render_rss_feed_for @todos, :feed => Todo.feed_options(@user),
                                    :item => {
                                                :title => :description,
                                                :link => lambda { |t| context_url(t.context) },
                                                :description => todo_feed_content
                                             }
      end
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
        render_atom_feed_for @todos, :feed => Todo.feed_options(@user),
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
        render :action => 'index_text', :layout => false, :content_type => Mime::TEXT
      end
    end

    def render_ical_feed
      lambda do
        render :action => 'index_ical', :layout => false, :content_type => Mime::ICS
      end
    end

    def self.is_feed_request(req)
        ['rss','atom','txt','ics'].include?(req.parameters[:format])
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

end
