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
      format.rss   &render_rss_feed
      format.atom  &render_atom_feed
      format.text  &render_text_feed
    end
  end

  def show
    @page_title = "TRACKS::Project: #{@project.name}"
    @not_done = @project.not_done_todos(:include_project_hidden_todos => true)
    @deferred = @project.deferred_todos
    @done = @project.done_todos
    @count = @not_done.size
    @next_project = @user.projects.next_from(@project)
    @previous_project = @user.projects.previous_from(@project)
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
    @go_to_project = params['go_to_project']
    @saved = @project.save
    @project_not_done_counts = { @project.id => 0 }
    @active_projects_count = @user.projects.count(:conditions => "state = 'active'")
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
      @state_changed = @project.state != params['project']['state']
      logger.info "@state_changed: #{@project.state} == #{params['project']['state']} != #{@state_changed}"
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
        @active_projects_count = @user.projects.count(:conditions => "state = 'active'")
        @hidden_projects_count = @user.projects.count(:conditions => "state = 'hidden'")
        @completed_projects_count = @user.projects.count(:conditions => "state = 'completed'")
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
    @active_projects_count = @user.projects.count(:conditions => "state = 'active'")
    @hidden_projects_count = @user.projects.count(:conditions => "state = 'hidden'")
    @completed_projects_count = @user.projects.count(:conditions => "state = 'completed'")
    respond_to do |format|
      format.js
      format.xml { render :text => "Deleted project #{@project.name}" }
    end
  end
  
  def order
    project_ids = params["list-active-projects"] || params["list-hidden-projects"] || params["list-completed-projects"]    
    projects = @user.projects.update_positions( project_ids )
    render :nothing => true
  rescue
    notify :error, $!
    redirect_to :action => 'index'
  end
  
  protected
    
    def render_projects_html
      lambda do
        init_project_hidden_todo_counts
        @page_title = "TRACKS::List Projects"
        @active_projects = @projects.select{ |p| p.active? }
        @hidden_projects = @projects.select{ |p| p.hidden? }
        @completed_projects = @projects.select{ |p| p.completed? }
        render
      end
    end

    def render_rss_feed
      lambda do
        render_rss_feed_for @projects, :feed => Project.feed_options(@user),
                                       :item => { :description => lambda { |p| p.summary(count_undone_todos_phrase(p)) } }
      end
    end

    def render_atom_feed
      lambda do
        render_atom_feed_for @projects, :feed => Project.feed_options(@user),
                                        :item => { :description => lambda { |p| p.summary(count_undone_todos_phrase(p)) },
                                                   :author => lambda { |p| nil } }
      end
    end

    def render_text_feed
      lambda do
        init_project_hidden_todo_counts(['project'])
        render :action => 'index_text', :layout => false, :content_type => Mime::TEXT
      end
    end
        
    def check_user_set_project
      @project = @user.projects.find_by_params(params)
      render :text => 'Project not found', :status => 404 if @project.nil?
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
