class TodoController < ApplicationController

  model :user
  model :project
  model :context

  helper :todo

  prepend_before_filter :login_required
  layout "standard"

  # Main method for listing tasks
  # Set page title, and fill variables with contexts and done and not-done tasks
  # Number of completed actions to show is determined by a setting in settings.yml
  def index
    self.init
    @projects = @user.projects.find(:all, :include => [ :todos ])
    @contexts = @user.contexts.find(:all, :include => [ :todos ])
    
    @on_page = "home"
    @page_title = "TRACKS::List tasks"
    
    # If you've set no_completed to zero, the completed items box
    # isn't shown on the home page
    max_completed = @user.preferences["no_completed"].to_i-1
    @done = nil
    if max_completed > 0
      @done = Todo.find(:all,
                        :conditions => ['todos.user_id = ? and todos.done = ?', @user.id, true],
                        :order => 'todos.completed DESC',
                        :limit => max_completed,
                        :include => [ :project, :context ])
    end
    
    @contexts_to_show = @contexts.reject {|x| x.hide? }
    
    if @contexts.empty?
      flash['warning'] = 'You must add at least one context before adding next actions.'
    end

    # Set count badge to number of not-done, not hidden context items
    @count = @todos.reject { |x| x.done? || x.context.hide? }.size
    
    respond_to do |wants|
      wants.html
      wants.xml { render :action => 'list.rxml', :layout => false }
    end
  end

  # Called by a form button
  # Parameters from form fields are passed to create new action
  # in the selected context.
  def add_item
    self.init
    @item = @user.todos.build
    @item.attributes = params["todo"]
    @on_page = "home"

    if @item.due?
      @item.due = parse_date_per_user_prefs(params["todo"]["due"])
    else
      @item.due = ""
    end

    @saved = @item.save

     respond_to do |wants|
       wants.html { redirect_to :action => "index" }
       wants.js do
         if @saved
           init_todos
           @up_count = @todos.reject { |x| x.done? or x.context.hide? }.size.to_s
         end
         render
       end
       wants.xml { render :xml => @item.to_xml( :root => 'todo', :except => :user_id ) }
     end

     # if you're seeing the message 'An error occurred on the server.' and you want to debug, comment out the rescue section and check the Ajax response for an exception message
     rescue
       respond_to do |wants|
         wants.html do
           flash["warning"] = 'An error occurred on the server.'
           render :action => "index"
        end
         wants.js { render :action => 'error' }
         wants.xml { render :text => 'An error occurred on the server.' + $! }
       end
  end
  
  def edit_action
    self.init
    @item = check_user_return_item
    render :layout => false
  end
  
  def show
    self.init
    item = check_user_return_item
    respond_to do |wants|
       wants.xml { render :xml => item.to_xml( :root => 'todo', :except => :user_id ) }
     end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    self.init

    @item = check_user_return_item
    @item.toggle!('done')
    @item.completed = Time.now() # For some reason, the before_save in todo.rb stopped working
    @saved = @item.save
    @on_page = "home"
    @remaining_undone_in_context = Todo.count(:conditions => ['user_id = ? and context_id = ? and type = ? and done = ?', @user.id, @item.context_id, "Immediate", false])
    if @saved
      @down_count = @todos.collect { |x| ( !x.done? and !x.context.hide? ) ? x:nil }.compact.size.to_s
    end
    return if request.xhr?

    if @saved
      flash['notice']  = "The action <strong>'#{@item.description}'</strong> was marked as <strong>#{@item.done? ? 'complete' : 'incomplete' }</strong>"
    else
      flash['notice']  = "The action <strong>'#{@item.description}'</strong> was NOT marked as <strong>#{@item.done? ? 'complete' : 'incomplete' } due to an error on the server.</strong>"
    end
    redirect_to :action => "index"
  end

  # Edit the details of an action
  #
  def update_action
    self.init
    if params["on_project_page"] == true
      @on_page = "project"
    end
    @item = check_user_return_item
    @original_item_context_id = @item.context_id
    @item.attributes = params["item"]

    if @item.due?
      @item.due = parse_date_per_user_prefs(params["item"]["due"])
    else
      @item.due = ""
    end

    @saved = @item.save
  end
  
  def update_context
    self.init
    @item = check_user_return_item
    context = Context.find(params['context_id']);
    if @user == context.user
      @original_item_context_id = @item.context_id
      @item.context_id = context.id
      @item.context = context
      @saved = @item.save
      render :action => 'update_action'
    else
      render :update do |page| 
        page.replace_html "info", content_tag("div", "Error updating the context of the dragged item. Item and context user mis-match: #{@item.user.name} and #{@context.user.name}! - refresh the page to see them.", "class" => "warning")
      end
    end
  end
  
  def update_project
    self.init
    @item = check_user_return_item
    project = Project.find(params['project_id']);
    if @user == project.user
      @original_item_context_id = @item.context_id
      @item.project_id = project.id
      @item.project = project
      @saved = @item.save
      render :action => 'update_action'
    else
      render :update do |page| 
        page.replace_html "info", content_tag("div", "Error updating the project of the dragged item. Item and project user mis-match: #{@item.user.name} and #{@project.user.name}! - refresh the page to see them.", "class" => "warning")
      end
    end
  end
  
  # Delete a next action
  #
  def destroy_action
    self.init
    @item = check_user_return_item
    context_id = @item.context_id
    
    @saved = @item.destroy
    @on_page = "home"
    @remaining_undone_in_context = Todo.count(:conditions => ['user_id = ? and context_id = ? and type = ? and done = ?', @user.id, context_id, "Immediate", false])
    if @saved
      self.init
      @down_count = @todos.reject { |x| x.done? or x.context.hide? }.size.to_s
    end
    
    return if request.xhr?
    
    # fallback for standard requests
    if @saved
      flash["notice"] = 'Successfully deleted next action'
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
    
    rescue
      if request.xhr? # be sure to include an error.rjs
        render :action => 'error'
      else
        flash["warning"] = 'An error occurred on the server.'
        render :action => 'index'
      end
  end

  # List the completed tasks, sorted by completion date
  # @done_today: in the last 24 hours
  # @done_this_week: in the last week
  # @done_this_month: in the last 4 weeks (<=28 days)
  def completed
    self.init
    @page_title = "TRACKS::Completed tasks"

    @done = Todo.find(:all,
                      :conditions => ['todos.user_id = ? and todos.done = ? and todos.completed is not null', @user.id, true],
                      :order => 'todos.completed DESC',
                      :include => [ :project, :context ])
    @done_today = @done.collect { |x| x.completed >= 1.day.ago ? x:nil }.compact
    @done_this_week = @done.collect { |x| 1.week.ago <= x.completed ? x:nil }.compact
    @done_this_month = @done.collect { |x| 4.week.ago <= x.completed ? x:nil }.compact
  end

  # Archived completed items, older than 28 days
  #
  def completed_archive
    self.init
    @page_title = "TRACKS::Archived completed tasks"
    @done = Todo.find(:all,
                      :conditions => ['todos.user_id = ? and todos.done = ? and todos.completed is not null', @user.id, true],
                      :order => 'todos.completed DESC',
                      :include => [ :project, :context ])
    @done_archive = @done.collect { |x| 28.day.ago > x.completed ? x:nil }.compact
  end
  
  protected

    def check_user_return_item
      item = Todo.find( params['id'] )
      if @user == item.user
        return item
      else
        flash["warning"] = "Item and session user mis-match: #{item.user.name} and #{@user.name}!"
        render_text ""
      end
    end

    def init
      @projects = @user.projects
      @contexts = @user.contexts
      init_todos
      init_not_done_counts
    end
    
    def init_todos
      @todos = Todo.find(:all,
                         :conditions => ['todos.user_id = ? and todos.type = ?', @user.id, "Immediate"],
                         :include => [ :project, :context ])

      @not_done_todos = Todo.find(:all,
                            :conditions => ['todos.user_id = ? and todos.type = ? and todos.done = ?', @user.id, "Immediate", false],
                            :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC",
                            :include => [ :project, :context ])
    end    
      
end
