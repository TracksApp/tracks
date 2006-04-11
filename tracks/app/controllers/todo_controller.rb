class TodoController < ApplicationController

  model :user
  model :project
  model :context

  helper :todo

  before_filter :login_required
  layout "standard"


  def index
    list
    render_action "list"
  end

  # Main method for listing tasks
  # Set page title, and fill variables with contexts and done and not-done tasks
  # Number of completed actions to show is determined by a setting in settings.yml
  #
  def list
    self.init
    @on_page = "home"
    @page_title = "TRACKS::List tasks"
    
    # If you've set no_completed to zero, the completed items box
    # isn't shown on the home page
    max_completed = @user.preferences["no_completed"].to_i-1
    @done = (max_completed > 0) ? @done[0..max_completed] : nil

    @contexts_to_show = @contexts.clone
    @contexts_to_show = @contexts_to_show.collect {|x| (!x.hide? and !x.find_not_done_todos.empty?) ? x:nil }.compact
    
    if @contexts.empty?
      flash['warning'] = 'You must add at least one context before adding next actions.'
    end

    # Set count badge to number of not-done, not hidden context items
    @count = @todos.collect { |x| ( !x.done? and !x.context.hide? ) ? x:nil }.compact.size
  end

  def update_element
  end
  
  # Called by a form button
  # Parameters from form fields are passed to create new action
  # in the selected context.
  def add_item
    self.init
    @item = @user.todos.build
    @item.attributes = @params["todo"]

    if @item.due?
      @item.due = Date.strptime(@params["todo"]["due"], @user.preferences["date_format"])
    else
      @item.due = ""
    end
    
    @saved = @item.save

    @on_page = "home"
    if @saved
      @up_count = @todos.collect { |x| ( !x.done? and !x.context.hide? ) ? x:nil }.compact.size.to_s
    end
    return if request.xhr?
    
    # fallback for standard requests
    if @saved
      flash["notice"] = 'Added new next action.'
      redirect_to :action => 'list'
    else
      flash["warning"] = 'The next action was not added. Please try again.'
      redirect_to :action => 'list'
    end
    
    rescue
      if request.xhr? # be sure to include an error.rjs
        render :action => 'error'
      else
        flash["warning"] = 'An error occurred on the server.'
        render :action => 'list'
      end
  end

  def edit_action
    self.init
    item = check_user_return_item

    render :partial => 'action_edit_form', :object => item
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
    if @saved
      @down_count = @todos.collect { |x| ( !x.done? and !x.context.hide? ) ? x:nil }.compact.size.to_s
    end
    return if request.xhr?

    if @saved
      flash['notice']  = "The action <strong>'#{@item.description}'</strong> was marked as <strong>#{@item.done? ? 'complete' : 'incomplete' }</strong>"
    else
      flash['notice']  = "The action <strong>'#{@item.description}'</strong> was NOT marked as <strong>#{@item.done? ? 'complete' : 'incomplete' } due to an error on the server.</strong>"
    end
    redirect_to :action => "list"
  end

  # Edit the details of an action
  #
  def update_action
    self.init
    if @params["on_project_page"] == true
      @on_page = "project"
    end
    @item = check_user_return_item
    @original_item_context_id = @item.context_id
    @item.attributes = @params["item"]

    if @item.due?
      @item.due = Date.strptime(@params["item"]["due"], @user.preferences["date_format"])
    else
      @item.due = ""
    end

    @saved = @item.save
  end

  # Delete a next action
  #
  def destroy_action
    self.init
    @item = check_user_return_item
    
    @saved = @item.destroy
    @on_page = "home"
    if @saved
      @down_count = @todos.collect { |x| ( !x.done? and !x.context.hide? ) ? x:nil }.compact.size.to_s
    end
    
    return if request.xhr?
    
    # fallback for standard requests
    if @saved
      flash["notice"] = 'Successfully deleted next action'
      redirect_to :action => 'list'
    else
      render :action => 'list'
    end
    
    rescue
      if request.xhr? # be sure to include an error.rjs
        render :action => 'error'
      else
        flash["warning"] = 'An error occurred on the server.'
        render :action => 'list'
      end
  end

  # List the completed tasks, sorted by completion date
  # @done_today: in the last 24 hours
  # @done_this_week: in the last week
  # @done_this_month: in the last 4 weeks (<=28 days)
  def completed
    self.init
    @page_title = "TRACKS::Completed tasks"

    unless @done.nil?
      @done_today = @done.collect { |x| x.completed >= 1.day.ago ? x:nil }.compact
      @done_this_week = @done.collect { |x| 1.week.ago <= x.completed ? x:nil }.compact
      @done_this_month = @done.collect { |x| 4.week.ago <= x.completed ? x:nil }.compact
    end
  end

  # Archived completed items, older than 28 days
  #
  def completed_archive
    self.init
    @page_title = "TRACKS::Archived completed tasks"
    @done_archive = @done.collect { |x| 28.day.ago > x.completed ? x:nil }.compact
  end
  
  def feeds
    self.init
    @page_title = "TRACKS::Feeds"
  end


  protected

    def check_user_return_item
      item = Todo.find( @params['id'] )
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
      @todos = @user.todos
      @done = @todos.find(:all, :conditions => ["done = ?", true])
    end
    
end
