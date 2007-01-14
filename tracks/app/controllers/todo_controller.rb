class TodoController < ApplicationController

  helper :todo

  append_before_filter :init, :except => [ :destroy, :completed, :completed_archive, :check_tickler ]
  layout 'standard'

  # Main method for listing tasks
  # Set page title, and fill variables with contexts and done and not-done tasks
  # Number of completed actions to show is determined by a setting in settings.yml
  def index
    @projects = @user.projects.find(:all, :include => [ :todos ])
    @contexts = @user.contexts.find(:all, :include => [ :todos ])
    
    @page_title = "TRACKS::List tasks"
    
    # If you've set no_completed to zero, the completed items box
    # isn't shown on the home page
    max_completed = @user.prefs.show_number_completed
    @done = @user.completed_todos.find(:all, :limit => max_completed) unless max_completed == 0
    
    @contexts_to_show = @contexts.reject {|x| x.hide? }

    # Set count badge to number of not-done, not hidden context items
    @count = @todos.reject { |x| !x.active? || x.context.hide? }.size
    
    respond_to do |wants|
      wants.html
      wants.xml { render :action => 'list.rxml', :layout => false }
    end
  end
  
  def create
    @item = @user.todos.build
    p = params['request'] || params
    # @item.tag_with(params[:tag_list])
    @item.attributes = p['todo']
    
    if p['todo']['project_id'].blank? && !p['project_name'].blank? && p['project_name'] != 'None'
      project = @user.projects.find_by_name(p['project_name'].strip)
      unless project
          project = @user.projects.build
          project.name = p['project_name'].strip
          project.save
          @new_project_created = true
      end
      @item.project_id = project.id
    end
    
    if p['todo']['context_id'].blank? && !p['context_name'].blank?
      context = @user.contexts.find_by_name(p['context_name'].strip)
      unless context
          context = @user.contexts.build
          context.name = p['context_name'].strip
          context.save
          @new_context_created = true
          @not_done_todos = [@item]
      end
      @item.context_id = context.id
    end

    if @item.due?
      @date = parse_date_per_user_prefs(p['todo']['due'])
      @item.due = @date
    else
      @item.due = ""
    end
    
    if p['todo']['show_from']
      @item.show_from = parse_date_per_user_prefs(p['todo']['show_from'])
    end

    @item.tag_with(params[:tag_list], @user)
    @saved = @item.save

     respond_to do |wants|
       wants.html { redirect_to :action => "index" }
       wants.js do
         if @saved
           determine_down_count
         end
         render :action => 'create'
       end
       wants.xml { render :xml => @item.to_xml( :root => 'todo', :except => :user_id ) }
     end
  end
  
  def edit
    @item = check_user_return_item
  end
  
  def show
    item = check_user_return_item
    respond_to do |wants|
       wants.xml { render :xml => item.to_xml( :root => 'todo', :except => :user_id ) }
     end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    @item = check_user_return_item
    @item.toggle_completion()
    @saved = @item.save
    respond_to do |format|
      format.js do
        if @saved
          @remaining_undone_in_context = @user.contexts.find(@item.context_id).not_done_todo_count
          determine_down_count
          determine_completed_count
        end
        render
      end
      format.html do
        if @saved
          # TODO: I think this will work, but can't figure out how to test it
          notify :notice, "The action <strong>'#{@item.description}'</strong> was marked as <strong>#{@item.completed? ? 'complete' : 'incomplete' }</strong>"
          redirect_to :action => "index"
        else
          notify :notice, "The action <strong>'#{@item.description}'</strong> was NOT marked as <strong>#{@item.completed? ? 'complete' : 'incomplete' } due to an error on the server.</strong>", "index"
          redirect_to :action =>  "index"
        end
      end
    end
  end

  def update
    @item = check_user_return_item
    @item.tag_with(params[:tag_list], @user)
    @original_item_context_id = @item.context_id
    @original_item_project_id = @item.project_id
    @original_item_was_deferred = @item.deferred?
    if params['item']['project_id'].blank? && !params['project_name'].blank? && params['project_name'] != 'None'
      project = @user.projects.find_by_name(params['project_name'].strip)
      unless project
          project = @user.projects.build
          project.name = params['project_name'].strip
          project.save
          @new_project_created = true
      end
      params["item"]["project_id"] = project.id
    end
    
    if params['item']['context_id'].blank? && !params['context_name'].blank?
      context = @user.contexts.find_by_name(params['context_name'].strip)
      unless context
          context = @user.contexts.build
          context.name = params['context_name'].strip
          context.save
          @new_context_created = true
      end
      params["item"]["context_id"] = context.id
    end
    
    if params["item"].has_key?("due")
      params["item"]["due"] = parse_date_per_user_prefs(params["item"]["due"])
    else
      params["item"]["due"] = ""
    end
    
    if params['item']['show_from']
      params['item']['show_from'] = parse_date_per_user_prefs(params['item']['show_from'])
    end
    
    
    
    @saved = @item.update_attributes params["item"]
    @context_changed = @original_item_context_id != @item.context_id
    @item_was_activated_from_deferred_state = @original_item_was_deferred && @item.active?
    if @context_changed then @remaining_undone_in_context = @user.contexts.find(@original_item_context_id).not_done_todos.length; end
    @project_changed = @original_item_project_id != @item.project_id
    if (@project_changed && !@original_item_project_id.nil?) then @remaining_undone_in_project = @user.projects.find(@original_item_project_id).not_done_todos.length; end
    determine_down_count
  end
    
  def destroy
    @item = check_user_return_item
    @context_id = @item.context_id
    @project_id = @item.project_id
    @saved = @item.destroy
    
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
               @remaining_undone_in_context = @user.contexts.find(@context_id).not_done_todos.length
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
    @done_today = @done.completed_within 1.day.ago.utc
    @done_this_week = @done.completed_within 1.week.ago.utc
    @done_this_month = @done.completed_within 4.week.ago.utc
  end

  def completed_archive
    @page_title = "TRACKS::Archived completed tasks"
    @done = @user.completed_todos
    @done_archive = @done.completed_more_than 28.day.ago.utc
  end
  
  def tickler
    @source_view = 'deferred'
    @page_title = "TRACKS::Tickler"
    @tickles = @user.deferred_todos
    @count = @tickles.size
  end
  
  # Check for any due tickler items, activate them
  # Called by periodically_call_remote
  def check_tickler
    @due_tickles = @user.deferred_todos.find_and_activate_ready
    respond_to do |format|
      format.html { redirect_to :controller => 'todo', :action => 'index' }
      format.js
    end
  end
  
  # /todo/tag/[tag_name] shows all the actions tagged with tag_name
  #
  def tag
    @tag = tag_name = params[:id]
    if Tag.find_by_name(tag_name)
      @todos = Todo.find_tagged_with(tag_name, @user)
    else 
      @todos = []
    end
    
    @count = @todos.size unless @todos.empty?
  end
  
  private

    def check_user_return_item
      item = Todo.find( params['id'].to_i )
      if @user == item.user
        return item
      else
        @error_message = 'Item and session user mis-match: #{item.user.name} and #{@user.name}!'
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
    
    def init_todos
      # Exclude hidden projects from count on home page
      @todos = @user.todos.find(:all, :conditions => ['todos.state = ? or todos.state = ?', 'active', 'complete'], :include => [ :project, :context ])

      # Exclude hidden projects from the home page
      @not_done_todos = @user.todos.find(:all, :conditions => ['todos.state = ?', 'active'], :order => "todos.due ASC", :include => [ :project, :context ])
    end
    
    def determine_down_count
      source_view do |from|
         from.todo do
           @down_count = Todo.count_by_sql(['SELECT COUNT(*) FROM todos, contexts WHERE todos.context_id = contexts.id and todos.user_id = ? and todos.state = ? and contexts.hide = ?', @user.id, 'active', false])
         end
         from.context do
           @down_count = @user.contexts.find(@item.context_id).not_done_todo_count
         end
         from.project do
           unless @item.project_id == nil
             @down_count = @user.projects.find(@item.project_id).not_done_todo_count
             @deferred_count = @user.projects.find(@item.project_id).deferred_todo_count
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
           @completed_count = @user.contexts.find(@item.context_id).done_todo_count
         end
         from.project do
           unless @item.project_id == nil
             @completed_count = @user.projects.find(@item.project_id).done_todo_count
           end
         end
      end
    end
          
end
