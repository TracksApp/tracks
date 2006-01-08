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
    @done = @done[0..(NO_OF_ACTIONS-1)]

    @contexts_to_show = @contexts.clone
    @contexts_to_show = @contexts_to_show.collect {|x| (!x.hidden? and !x.find_not_done_todos.empty?) ? x:nil }.compact

    # Set count badge to number of not-done, not hidden context items
    @count = @todos.collect { |x| ( !x.done? and !x.context.hidden? ) ? x:nil }.compact.size
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
      @item.due = Date.strptime(@params["todo"]["due"], DATE_FORMAT)
    else
      @item.due = ""
    end

    @saved = @item.save
    @on_page = "home"
    @up_count = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = 0", @user.id]).size.to_s
    
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

    item = check_user_return_item
    item.toggle!('done')
    item.completed = Time.now() # For some reason, the before_save in todo.rb stopped working
    if item.save
      if request.xhr?
        render :partial => 'item', :object => item
      else
        flash['notice']  = "The item <strong>'#{item.description}'</strong> was marked as <strong>#{item.done? ? 'complete' : 'incomplete' }</strong>"
        redirect_to :action => "list"
      end
    end
  end

  # Edit the details of an action
  #
  def update_action
    self.init
    if @params["on_project_page"] == true
      @on_page = "project"
    end
    item = check_user_return_item
    item.attributes = @params["item"]

    if item.due?
      item.due = Date.strptime(@params["item"]["due"], DATE_FORMAT)
    else
      item.due = ""
    end

    if item.save
	    render :partial => 'item', :object => item
    else
      flash["warning"] = "Couldn't update the action"
      render_text ""
    end
  end

  # Delete a next action
  #
  def destroy_action
    self.init
    @item = check_user_return_item
    
    @saved = @item.destroy
    @down_count = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = 0", @user.id]).size.to_s
    
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
  #
  # Use days declaration? 1.day.ago?
  def completed
    self.init
    @page_title = "TRACKS::Completed tasks"

    day = (60 * 60 * 24)
    today = Time.now

    today_date = today - (1 * day)
    week_begin = today - (1 * day)
    week_end = today - (7 * day)
    month_begin = today - (8 * day)
    month_end = today - (31 * day)

    @done_today = @done.collect { |x| today_date <= x.completed ? x:nil }.compact
    @done_this_week = @done.collect { |x| week_begin >= x.completed && week_end <= x.completed ? x:nil }.compact
    @done_this_month = @done.collect { |x| month_begin >= x.completed && month_end <= x.completed ? x:nil }.compact

  end

  # Archived completed items, older than 31 days
  #
  def completed_archive
    self.init
    @page_title = "TRACKS::Archived completed tasks"
    archive_date = Time.now - 32 * (60 * 60 * 24)
    @done_archive = @done.collect { |x| archive_date >= x.completed ? x:nil }.compact
  end


  protected

    def check_user_return_item
      item = Todo.find( @params['id'] )
      if @session['user'] == item.user
        return item
      else
        flash["warning"] = "Item and session user mis-match: #{item.user.name} and #{@session['user'].name}!"
        render_text ""
      end
    end

    def init
      @user = @session['user']
      @projects = @user.projects
      @contexts = @user.contexts
      @todos = @user.todos
      @done = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = 1", @user.id], :include => [:project], :order => "completed DESC")
      # for some reason, this generates an error about anil object under 0.14.2
      #@done = @todos.collect { |x|  x.done? ? x:nil }.compact.sort! {|x,y| y.completed <=> x.completed }
    end
    
end
