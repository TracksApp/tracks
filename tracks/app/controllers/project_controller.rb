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
    @page_title = "TRACKS::Project: #{@project.name}"
  end

  def new_project
    project = @session['user'].projects.build
    project.attributes = @params['project']
    project.name = deurlize(project.name)

    if project.save
      render :partial => 'project_listing', :locals => { :project_listing => project }
    else
      flash["warning"] = "Couldn't update new project"
      render :text => ""
    end
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
  
  # Toggles the 'done' status of the action
  #
  def toggle_check
    self.init

    item = check_user_return_item
    item.toggle!('done')
    item.completed = Time.now () # For some reason, the before_save in todo.rb stopped working
    if item.save
      render :partial => 'project/show_items', :object => item
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
    
    def check_user_return_item
      item = Todo.find( @params['id'] )
      if @session['user'] == item.user
        return item
      else
        flash["warning"] = "Item and session user mis-match: #{item.user.name} and #{@session['user'].name}!"
        render_text ""
      end
    end

    def check_user_set_project
      @user = @session['user']
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
        flash["warning"] = "Project and session user mis-match: #{@project.user_id} and #{@session['user'].id}!"
        render_text ""
      end
    end
    
    def check_user_matches_project_user(id)
      @user = @session['user']
      @project = Project.find_by_id_and_user_id(id, @user.id)
      if @user == @project.user
        return @project
      else
        @project = nil
        flash["warning"] = "Project and session user mis-match: #{@project.user_id} and #{@session['user'].id}!"
        render_text ""
      end
    end
    
    def init
      @user = @session['user']
      @projects = @user.projects
      @contexts = @user.contexts
    end

    def init_todos
      check_user_set_project
      @done = @project.find_done_todos
      @not_done = @project.find_not_done_todos
      @count = @not_done.size
    end

end
