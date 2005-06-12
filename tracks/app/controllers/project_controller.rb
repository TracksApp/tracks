class ProjectController < ApplicationController
  
  helper :project
  model :context
  model :todo
  
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
    @page_title = "TRACKS::List Projects"
    @projects = Project.find( :all, :order => "position ASC" )
  end
  
  # Filter the projects to show just the one passed in the URL
  # e.g. <home>/project/show/<project_name> shows just <project_name>.
  #
  def show
    @project = Project.find_by_name(deurlize(@params["name"]))
    @places = Context.find(:all, :order => "position ASC")
    @projects = Project.find( :all, :conditions => "done=0", :order => "position ASC" )
    @page_title = "TRACKS::Project: #{@project.name}"
    @not_done = Todo.find(:all, :conditions => "done=0 AND project_id=#{@project.id}", 
                          :order => "due IS NULL, due ASC, created ASC")
    @done = Todo.find(:all, :conditions => "done=1 AND project_id=#{@project.id}", 
                          :order => "completed DESC")
    @count = @not_done.length
  end
  
  def new_project
     @project = Project.new(@params['project'])
     if @project.save
       render_partial( 'project_listing', @project )
     else
       flash["warning"] = "Couldn't update new project"
      render_text ""
     end
  end
  
  # Edit the details of the project
  #  
  def update
    project = Project.find(params[:id])
    project.attributes = @params["project"]
    if project.save
      render_partial 'project_listing', project
    else
      flash["warning"] = "Couldn't update new project"
      render_text ""
    end
  end
  
  # Edit the details of the action in this project
  #
  def update_action
    @places = Context.find(:all, :order => "position ASC")
    @projects = Project.find( :all, :conditions => "done=0", :order => "position ASC" )
    action = Todo.find(params[:id])
    action.attributes = @params["item"]
    
    if action.due?
      action.due = Date.strptime(@params["item"]["due"], DATE_FORMAT)
    else
      action.due = ""
    end
        
    if action.save
      render_partial 'show_items', action
    else
      flash["warning"] = "Couldn't update the action"
      render_text ""
    end
  end
  
  # Called by a form button
  # Parameters from form fields are passed to create new action
  #
  def add_item
    @projects = Project.find( :all, :conditions => "done=0", :order => "position ASC" )
    @places = Context.find( :all, :order => "position ASC" )

    item = Todo.new
    item.attributes = @params["new_item"]

    if item.due?
      item.due = Date.strptime(@params["new_item"]["due"], DATE_FORMAT)
    else
      item.due = ""
    end

     if item.save
       render_partial 'show_items', item
     else
       flash["warning"] = "Couldn't add next action  \"#{item.description}\""
       render_text ""
     end
  end
  
  # Delete a project
  #
  def destroy
    this_project = Project.find( @params['id'] )
    if this_project.destroy
      render_text ""
    else
      flash["warning"] = "Couldn't delete project \"#{project.name}\""
      redirect_to( :controller => "project", :action => "list" )
    end
  end
  
  
  # Delete a next action in a project
  #
  def destroy_action
    item = Todo.find(@params['id'])
    if item.destroy
      #flash["confirmation"] = "Next action \"#{item.description}\" was successfully deleted"
      render_text ""
    else
      flash["warning"] = "Couldn't delete next action \"#{item.description}\""
      redirect_to :action => "list"
    end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    @places = Context.find(:all, :order => "position ASC")  
    @projects = Project.find( :all, :conditions => "done=0", :order => "position ASC" )
    item = Todo.find(@params['id'])

    item.toggle!('done')
    render_partial 'show_items', item
  end
  
  # Methods for changing the sort order of the projects in the list
  #
  def move_up
    line = Project.find(params[:id])
    line.move_higher
    line.save
    redirect_to(:controller => "project", :action => "list")
  end

  def move_down
    line = Project.find(params[:id])
    line.move_lower
    line.save
    redirect_to(:controller => "project", :action => "list")
  end

  def move_top
    line = Project.find(params[:id])
    line.move_to_top
    line.save
    redirect_to(:controller => "project", :action => "list")
  end

  def move_bottom
    line = Project.find(params[:id])
    line.move_to_bottom
    line.save
    redirect_to(:controller => "project", :action => "list" )
  end
  
    
end
