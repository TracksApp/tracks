class ProjectController < ApplicationController

  helper :todo
  prepend_before_filter :login_required
  before_filter :init, :except => [:create, :destroy, :order, :toggle_project_done]
  before_filter :init_todos, :only => :show

  layout "standard", :except => :date_preview

  def index
    list
    render_action "list"
  end

  # Main method for listing projects
  # Set page title, and collect existing projects in @projects
  #
  def list
    init_project_hidden_todo_counts
    @page_title = "TRACKS::List Projects"
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @projects.to_xml( :except => :user_id )  }
    end
  end

  # Filter the projects to show just the one passed in the URL
  # e.g. <home>/project/show/<project_name> shows just <project_name>.
  #
  def show
    @notes = @project.notes
    @page_title = "TRACKS::Project: #{@project.name}"
    
    if @contexts.empty?
      notify :warning, 'You must add at least one context before adding next actions.'
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

  # Example XML usage: curl -H 'Accept: application/xml' -H 'Content-Type: application/xml'
  #                    -u username:password
  #                    -d '<request><project><name>new project_name</name></project></request>'
  #                    http://our.tracks.host/project/create
  #
  def create
    if params[:format] == 'application/xml' && params['exception']
      render_failure "Expected post format is valid xml like so: <request><project><name>project name</name></project></request>."
      return
    end
    @project = @user.projects.build
    params_are_invalid = true
    if (params['project'] || (params['request'] && params['request']['project']))
      @project.attributes = params['project'] || params['request']['project']
      params_are_invalid = false
    end
    @project.name = deurlize(@project.name)
    @saved = @project.save
    @project_not_done_counts = { @project.id => 0 }
    respond_to do |wants|
      wants.js
      wants.xml do
        if @project.new_record? && params_are_invalid
          render_failure "Expected post format is valid xml like so: <request><project><name>project name</name></project></request>."
        elsif @project.new_record?
          render_failure @project.errors.full_messages.join(', ')
        else
          render :xml => @project.to_xml( :except => :user_id )
       end
      end
    end
  end

  # Edit the details of the project
  #
  def update
    check_user_set_project
    params['project'] ||= {}
    if params['project']['state']
      @project.transition_to(params['project']['state'])
      params['project'].delete('state')
    end
    success_text = if params['field'] == 'name' && params['value']
      params['project']['id'] = params['id'] 
      params['project']['name'] = params['value'] 
    end
    @project.attributes = params['project']
    @project.name = deurlize(@project.name)
    if @project.save
      if params['wants_render']
        if (@project.hidden?)
          @project_project_hidden_todo_counts = Hash.new
          @project_project_hidden_todo_counts[@project.id] = @project.reload().not_done_todo_count(:include_project_hidden_todos => true)
        else
          @project_not_done_counts[@project.id] = @project.reload().not_done_todo_count(:include_project_hidden_todos => true)
        end
        render
      else
        render :text => success_text || 'Success'
      end
    else
      notify :warning, "Couldn't update project"
      render :text => ''
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
      render :text => ''
    else
      notify :warning, "Couldn't delete project \"#{@project.name}\""
      redirect_to( :controller => "project", :action => "list" )
    end
  end

  # Methods for changing the sort order of the projects in the list
  #
  def order
    params["list-projects"].each_with_index do |id, position|
      if check_user_matches_project_user(id)
        Project.update(id, :position => position + 1)
      end
    end
    render :nothing => true
  end
  
  protected
    
    def check_user_set_project
      if params["name"]
        @project = Project.find_by_name_and_user_id(deurlize(params["name"]), @user.id)
      elsif params['id']
        @project = Project.find_by_id_and_user_id(params["id"], @user.id)
      else
        redirect_to(:controller => "project", :action => "list" )
      end
      if @user == @project.user
        return @project
      else
        @project = nil # Should be nil anyway
        notify :warning, "Project and session user mis-match: #{@project.user_id} and #{@user.id}!"
        render :text => ''
      end
    end
    
    def check_user_matches_project_user(id)
      @project = Project.find_by_id_and_user_id(id, @user.id)
      if @user == @project.user
        return @project
      else
        @project = nil
        notify :warning, "Project and session user mis-match: #{@project.user_id} and #{@user.id}!"
        render :text => ''
      end
    end
    
    def check_user_return_item
      item = Todo.find( params['id'] )
      if @user == item.user
        return item
      else
        notify :warning, "Item and session user mis-match: #{item.user.name} and #{@user.name}!"
        render :text => ''
      end
    end
     
    def init
      @source_view = params['_source_view'] || 'project'
      @projects = @user.projects
      @contexts = @user.contexts
      @todos = @user.todos
      @done = @user.todos.find_in_state(:all, :completed, :order => "completed_at DESC")
      init_data_for_sidebar
    end

    def init_todos
      check_user_set_project
      @done = @project.done_todos
      @not_done = @project.not_done_todos(:include_project_hidden_todos => true)
      @count = @not_done.size
    end

end
