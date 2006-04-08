class ProjectController < ApplicationController

  model :todo

  helper :todo
  before_filter :login_required

  layout "standard"

  def index
    list
    render_action "list"
  end

  # Main method for listing projects
  # Set page title, and collect existing projects in @projects
  #
  def list
    init
    @page_title = "TRACKS::List Projects"
  end

  # Filter the projects to show just the one passed in the URL
  # e.g. <home>/project/show/<project_name> shows just <project_name>.
  #
  def show
    init
    init_todos
    @notes = @project.notes
    @on_page = "project"
    @page_title = "TRACKS::Project: #{@project.name}"
    
    if @contexts.empty?
      flash['warning'] = 'You must add at least one context before adding next actions.'
    end
    
    if @not_done.empty?
      @msg_nd = "Currently there are no uncompleted actions in this project"
    else
      @msg_nd = nil
    end
    
    if @done.empty?
      @msg_d = "Currently there are no completed actions in this project"
    else
      @msg_d = nil
    end
    
    if @notes.empty?
      @msg_n = "Currently there are no notes attached to this project"
    else
      @msg_n = nil
    end
  end

  def new_project
    project = @user.projects.build
    project.attributes = @params['project']
    project.name = deurlize(project.name)

    if project.save
      render :partial => 'project_listing', :locals => { :project_listing => project }
    else
      flash["warning"] = "Couldn't update new project"
      render :text => ""
    end
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
    @on_page = "project"
    if @saved
      @up_count = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = ? and todos.project_id IN (?)", @user.id, false, @item.project_id]).size.to_s
    end
    
    return if request.xhr?
    
    # fallback for standard requests
    if @saved
      flash["notice"] = 'Added new next action.'
      redirect_to :controller => 'todo', :action => 'list'
    else
      flash["warning"] = 'The next action was not added. Please try again.'
      redirect_to :controller => 'todo', :action => 'list'
    end
    
    rescue
      if request.xhr? # be sure to include an error.rjs
        render :action => 'error'
      else
        flash["warning"] = 'An error occurred on the server.'
        redirect_to :controller => 'todo', :action => 'list'
      end
  end
  
  # Delete a next action
  #
  def destroy_action
    self.init
    @item = check_user_return_item
    
    @saved = @item.destroy
    @on_page = "project"
    if @saved
      @down_count = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = ? and todos.project_id IN (?)", @user.id, false, @item.project_id]).size.to_s
    end
    
    return if request.xhr?
    
    # fallback for standard requests
    if @saved
      flash["notice"] = 'Successfully deleted next action'
      redirect_to :controller => 'todo', :action => 'list'
    else
      render :controller => 'todo', :action => 'list'
    end
    
    rescue
      if request.xhr? # be sure to include an error.rjs
        render :action => 'error'
      else
        flash["warning"] = 'An error occurred on the server.'
        render :controller => 'todo', :action => 'list'
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
    @on_page = "project"
    if @saved
      @down_count = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = ? and todos.project_id IN (?)", @user.id, false, @item.project_id]).size.to_s
      @done_count = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = ? and todos.project_id IN (?)", @user.id, true, @item.project_id]).size.to_s
    end
    return if request.xhr?

    if @saved
      flash['notice']  = "The action <strong>'#{@item.description}'</strong> was marked as <strong>#{@item.done? ? 'complete' : 'incomplete' }</strong>"
    else
      flash['notice']  = "The action <strong>'#{@item.description}'</strong> was NOT marked as <strong>#{@item.done? ? 'complete' : 'incomplete' } due to an error on the server.</strong>"
    end
    redirect_to :action => "list"
  end
  
  # Edit the details of the project
  #
  def update
    check_user_set_project
    @project.attributes = @params["project"]
    @project.name = deurlize(@project.name)
    if @project.save
      render_partial 'project_listing', @project
    else
      flash["warning"] = "Couldn't update project"
      render_text ""
    end
  end
  
  # Toggles the 'done' status of a project
  #
  def toggle_project_done
    check_user_set_project
    
    @project.toggle!('done')
    if @project.save
      redirect_to(:action => "list")
    end
  end

  # Delete a project
  #
  def destroy
    check_user_set_project
    if @project.destroy
      render_text ""
    else
      flash["warning"] = "Couldn't delete project \"#{@project.name}\""
      redirect_to( :controller => "project", :action => "list" )
    end
  end

  # Methods for changing the sort order of the projects in the list
  #
  def order
    @params["list-projects"].each_with_index do |id, position|
      if check_user_matches_project_user(id)
        Project.update(id, :position => position + 1)
      end
    end
    render :nothing => true
  end
  
  protected
    
    def check_user_set_project
      if @params["name"]
        @project = Project.find_by_name_and_user_id(deurlize(@params["name"]), @user.id)
      elsif @params['id']
        @project = Project.find_by_id_and_user_id(@params["id"], @user.id)
      else
        redirect_to(:controller => "project", :action => "list" )
      end
      if @user == @project.user
        return @project
      else
        @project = nil # Should be nil anyway
        flash["warning"] = "Project and session user mis-match: #{@project.user_id} and #{@user.id}!"
        render_text ""
      end
    end
    
    def check_user_matches_project_user(id)
      @project = Project.find_by_id_and_user_id(id, @user.id)
      if @user == @project.user
        return @project
      else
        @project = nil
        flash["warning"] = "Project and session user mis-match: #{@project.user_id} and #{@user.id}!"
        render_text ""
      end
    end
    
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
      @done = Todo.find(:all, :conditions => ["todos.user_id = ? and todos.done = ?", @user.id, true], :include => [:project], :order => "completed DESC")
    end

    def init_todos
      check_user_set_project
      @done = @project.find_done_todos
      @not_done = @project.find_not_done_todos
      @count = @not_done.size
    end

end
