class ProjectsController < ApplicationController

  helper :application, :todos, :notes
  before_filter :init, :except => [:create, :destroy, :order]
  before_filter :check_user_set_project, :only => [:update, :destroy, :show]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]
  session :off, :only => :index, :if => Proc.new { |req| ['rss','atom','txt'].include?(req.parameters[:format]) }

  def index
    if params[:only_active_with_no_next_actions]
      @projects = @projects.select { |p| p.active? && count_undone_todos(p) == 0 }
    end
    respond_to do |format|
      format.html  &render_projects_html
      format.xml   { render :xml => @projects.to_xml( :except => :user_id )  }
      format.rss   &render_projects_rss_feed
      format.atom  &render_projects_atom_feed
      format.text  { render :action => 'index_text', :layout => false, :content_type => Mime::TEXT }
    end
  end

  def show
    @page_title = "TRACKS::Project: #{@project.name}"
    @not_done = @project.not_done_todos(:include_project_hidden_todos => true)
    @deferred = @project.deferred_todos
    @done = @project.done_todos
    @count = @not_done.size
  end

  # Example XML usage: curl -H 'Accept: application/xml' -H 'Content-Type: application/xml'
  #                    -u username:password
  #                    -d '<request><project><name>new project_name</name></project></request>'
  #                    http://our.tracks.host/projects
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
    if @project.save
      if boolean_param('wants_render')
        if (@project.hidden?)
          @project_project_hidden_todo_counts = Hash.new
          @project_project_hidden_todo_counts[@project.id] = @project.reload().not_done_todo_count(:include_project_hidden_todos => true)
        else
          @project_not_done_counts[@project.id] = @project.reload().not_done_todo_count(:include_project_hidden_todos => true)
        end
        render
      elsif boolean_param('update_status')
        render :action => 'update_status'
      else
        render :text => success_text || 'Success'
      end
    else
      notify :warning, "Couldn't update project"
      render :text => ''
    end
  end
  
  def destroy
    @project.destroy
    respond_to do |format|
      format.js
      format.xml { render :text => "Deleted project #{@project.name}" }
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
    
    def render_projects_html
      lambda do
        init_project_hidden_todo_counts
        @page_title = "TRACKS::List Projects"
        render
      end
    end

    def render_projects_rss_feed
      lambda do
        render_rss_feed_for @projects, :feed => Project.feed_options(@user),
                                       :item => { :description => lambda { |p| p.summary(count_undone_todos_phrase(p)) } }
      end
    end

    def render_projects_atom_feed
      lambda do
        render_atom_feed_for @projects, :feed => Project.feed_options(@user),
                                        :item => { :description => lambda { |p| p.summary(count_undone_todos_phrase(p)) },
                                                   :author => lambda { |p| nil } }
      end
    end
    
    def check_user_set_project
      @project = @user.projects.find_by_params(params)
      render :text => 'Project not found', :status => 404 if @project.nil?
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

end
