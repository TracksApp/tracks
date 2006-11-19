class TodoController < ApplicationController

  model :user
  model :project
  model :context

  helper :todo

  prepend_before_filter :login_required
  append_before_filter :init, :except => [ :destroy, :completed, :completed_archive ]
  layout "standard", :except => :date_preview

  # Main method for listing tasks
  # Set page title, and fill variables with contexts and done and not-done tasks
  # Number of completed actions to show is determined by a setting in settings.yml
  def index
    init
    @projects = @user.projects.find(:all, :include => [ :todos ])
    @contexts = @user.contexts.find(:all, :include => [ :todos ])
    
    @page_title = "TRACKS::List tasks"
    
    # If you've set no_completed to zero, the completed items box
    # isn't shown on the home page
    max_completed = @user.preference.show_number_completed - 1
    @done = nil
    if max_completed > 0
      @done = Todo.find(:all,
                        :conditions => ['todos.user_id = ? and todos.state = ?', @user.id, 'completed'],
                        :order => 'todos.completed_at DESC',
                        :limit => max_completed,
                        :include => [ :project, :context ])
    end
    
    @contexts_to_show = @contexts.reject {|x| x.hide? }
    
    if @contexts.empty?
      notify :warning, "You must add at least one context before adding next actions."
    end

    # Set count badge to number of not-done, not hidden context items
    @count = @todos.reject { |x| !x.active? || x.context.hide? }.size
    
    respond_to do |wants|
      wants.html
      wants.xml { render :action => 'list.rxml', :layout => false }
    end
  end

  def date_preview
    return if params["todo_due"].blank?
    @date = parse_date_per_user_prefs(params["todo_due"])
    
    if @date.nil?
      @form_date = "Invalid date"
    else
      @form_date = @date.strftime("%a %b %d %Y")
    end
    render :partial => "shared/date_preview", :layout => false
  end
  
  def create
    init
    @item = @user.todos.build
    p = params['todo'] || params['request']['todo']
    @item.attributes = p

    if @item.due?
      @date = parse_date_per_user_prefs(p["due"])
      @item.due = @date.to_s(:db)
    else
      @item.due = ""
    end

    @saved = @item.save

     respond_to do |wants|
       wants.html { redirect_to :action => "index" }
       wants.js do
         if @saved
           init_todos
           @up_count = @todos.reject { |x| !x.active? or x.context.hide? }.size.to_s
         end
         render :action => 'create'
       end
       wants.xml { render :xml => @item.to_xml( :root => 'todo', :except => :user_id ) }
     end

     # if you're seeing the message 'An error occurred on the server.' and you want to debug, comment out the rescue section and check the Ajax response for an exception message
     rescue
       respond_to do |wants|
         wants.html do
           notify :warning, "An error occurred on the server."
           render :action => "index"
         end
         wants.js { render :action => 'error' }
         wants.xml { render :text => 'An error occurred on the server.' + $! }
       end
  end

  def add_item
    create
  end
  
  def edit
    init
    @item = check_user_return_item
  end
  
  def show
    init
    item = check_user_return_item
    respond_to do |wants|
       wants.xml { render :xml => item.to_xml( :root => 'todo', :except => :user_id ) }
     end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    init
    logger.info "source view is " + @source_view
    @item = check_user_return_item
    @item.toggle_completion()
    @saved = @item.save
    if @saved
      @remaining_undone_in_context = @user.contexts.find(@item.context_id).not_done_todo_count
      determine_down_count
    end
    return if request.xhr?

    if @saved
      # TODO: I think this will work, but can't figure out how to test it
      notify :notice, "The action <strong>'#{@item.description}'</strong> was marked as <strong>#{@item.completed? ? 'complete' : 'incomplete' }</strong>"
      redirect_to :action => "index"
    else
      notify :notice, "The action <strong>'#{@item.description}'</strong> was NOT marked as <strong>#{@item.completed? ? 'complete' : 'incomplete' } due to an error on the server.</strong>", "index"
      redirect_to :action =>  "index"
    end
  end

  def update
    init
    @item = check_user_return_item
    @original_item_context_id = @item.context_id
    @original_item_project_id = @item.project_id
    @item.attributes = params["item"]
    if params["item"].has_key?("due")
      params["item"]["due"] = parse_date_per_user_prefs(params["item"]["due"])
    else
      params["item"]["due"] = ""
    end
    @saved = @item.update_attributes params["item"]
    @context_changed = @original_item_context_id != @item.context_id
    if @context_changed then @remaining_undone_in_context = @user.contexts.find(@original_item_context_id).not_done_todos.length; end
    @project_changed = @original_item_project_id != @item.project_id
    if (@project_changed && !@original_item_project_id.nil?) then @remaining_undone_in_project = @user.projects.find(@original_item_project_id).not_done_todos.length; end
  end
  
  def update_context
    init
    @item = check_user_return_item
    context = Context.find(params['context_id']);
    if @user == context.user
      @original_item_context_id = @item.context_id
      @item.context_id = context.id
      @item.context = context
      @saved = @item.save
      render :action => 'update'
    else
      render :update do |page| 
        page.notify :warning, content_tag("div", "Error updating the context of the dragged item. Item and context user mis-match: #{@item.user.name} and #{@context.user.name}! - refresh the page to see them."), 8.0
      end
    end
  end
  
  def update_project
    init
    @item = check_user_return_item
    project = Project.find(params['project_id']);
    if @user == project.user
      @original_item_context_id = @item.context_id
      @item.project_id = project.id
      @item.project = project
      @saved = @item.save
      render :action => 'update'
    else
      render :update do |page| 
        page.notify :warning, content_tag("div", "Error updating the project of the dragged item. Item and project user mis-match: #{@item.user.name} and #{@project.user.name}! - refresh the page to see them."), 8.0
      end
    end
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
    
    rescue
      respond_to do |wants|
        wants.html do
          notify :error, 'An error occurred on the server.', 8.0
          redirect_to :action => 'index'
        end
        wants.js { render :action => 'error' }
        wants.xml { render :text => 'An error occurred on the server.' + $! }
      end    
  end

  def completed
    @page_title = "TRACKS::Completed tasks"
    @done = Todo.find_completed(@user.id)
    @done_today = @done.completed_within 1.day.ago
    @done_this_week = @done.completed_within 1.week.ago
    @done_this_month = @done.completed_within 4.week.ago
  end

  def completed_archive
    @page_title = "TRACKS::Archived completed tasks"
    @done = Todo.find_completed(@user.id)
    @done_archive = @done.completed_more_than 28.day.ago
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
      @not_done_todos = @user.todos.find(:all, :conditions => ['todos.state = ?', 'active'], :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC", :include => [ :project, :context ])
    end
    
    def determine_down_count
      source_view do |from|
         from.todo do
           @down_count = Todo.count_by_sql(['SELECT COUNT(*) FROM todos, contexts WHERE todos.context_id = contexts.id and todos.user_id = ? and todos.state = ? and contexts.hide = ?', @user.id, 'active', false])
         end
         from.context do
           @down_count = @user.contexts.find(@item.context_id).todos.count_in_state(:active)
         end
         from.project do
           unless @item.project_id == nil
             @down_count = @user.projects.find(@item.project_id).todos.count_in_state(:active)
           end
         end
      end
    end 
      
end
