class ProjectsController < ApplicationController

  helper :application, :todos, :notes
  before_filter :set_source_view
  before_filter :set_project_from_params, :only => [:update, :destroy, :show, :edit]
  before_filter :default_context_filter, :only => [:create, :update]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]
  session :off, :only => :index, :if => Proc.new { |req| ['rss','atom','txt'].include?(req.parameters[:format]) }

  def index
    @projects = current_user.projects(true)
    @contexts = current_user.contexts(true)
    init_not_done_counts(['project'])
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
    init_data_for_sidebar
    @page_title = "TRACKS::Project: #{@project.name}"
    @project.todos.with_scope :find => { :include => [:context, :tags] } do
      @not_done = @project.not_done_todos(:include_project_hidden_todos => true)
      @deferred = @project.deferred_todos.sort_by { |todo| todo.show_from }
      @done = @project.done_todos
    end
    
    @max_completed = current_user.prefs.show_number_completed
    
    @count = @not_done.size
    @next_project = current_user.projects.next_from(@project)
    @previous_project = current_user.projects.previous_from(@project)
    @default_project_context_name_map = build_default_project_context_name_map(@projects).to_json
    respond_to do |format|
      format.html
      format.xml   { render :xml => @project.to_xml( :except => :user_id )  }
    end
  end
  
  # Example XML usage: curl -H 'Accept: application/xml' -H 'Content-Type:
  # application/xml'
  #                    -u username:password
  #                    -d '<request><project><name>new project_name</name></project></request>'
  #                    http://our.tracks.host/projects
  # 
  def create
    if params[:format] == 'application/xml' && params['exception']
      render_failure "Expected post format is valid xml like so: <request><project><name>project name</name></project></request>."
      return
    end
    @project = current_user.projects.build
    params_are_invalid = true
    if (params['project'] || (params['request'] && params['request']['project']))
      @project.attributes = params['project'] || params['request']['project']
      params_are_invalid = false
    end
    @go_to_project = params['go_to_project']
    @saved = @project.save
    @project_not_done_counts = { @project.id => 0 }
    @active_projects_count = current_user.projects.count(:conditions => "state = 'active'")
    @contexts = current_user.contexts
    respond_to do |format|
      format.js { @down_count = current_user.projects.size }
      format.xml do
        if @project.new_record? && params_are_invalid
          render_failure "Expected post format is valid xml like so: <request><project><name>project name</name></project></request>."
        elsif @project.new_record?
          render_failure @project.errors.full_messages.join(', ')
        else
          head :created, :location => project_url(@project)
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
          @project_not_done_counts = Hash.new
          @project_not_done_counts[@project.id] = @project.reload().not_done_todo_count(:include_project_hidden_todos => true)
        end
        @contexts = current_user.contexts
        @active_projects_count = current_user.projects.count(:conditions => "state = 'active'")
        @hidden_projects_count = current_user.projects.count(:conditions => "state = 'hidden'")
        @completed_projects_count = current_user.projects.count(:conditions => "state = 'completed'")
        render
      elsif boolean_param('update_status')
        render :action => 'update_status'
      elsif boolean_param('update_default_context')
        render :action => 'update_default_context'
      else
        render :text => success_text || 'Success'
      end
    else
      notify :warning, "Couldn't update project"
      render :text => ''
    end
  end
  
  def edit
    @contexts = current_user.contexts
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @project.destroy
    @active_projects_count = current_user.projects.count(:conditions => "state = 'active'")
    @hidden_projects_count = current_user.projects.count(:conditions => "state = 'hidden'")
    @completed_projects_count = current_user.projects.count(:conditions => "state = 'completed'")
    respond_to do |format|
      format.js { @down_count = current_user.projects.size }
      format.xml { render :text => "Deleted project #{@project.name}" }
    end
  end
  
  def order
    project_ids = params["list-active-projects"] || params["list-hidden-projects"] || params["list-completed-projects"]    
    projects = current_user.projects.update_positions( project_ids )
    render :nothing => true
  rescue
    notify :error, $!
    redirect_to :action => 'index'
  end
  
  def alphabetize
    @state = params['state']
    @projects = current_user.projects.alphabetize(:state => @state) if @state
    @contexts = current_user.contexts
    init_not_done_counts(['project'])
  end
  
  protected
    
  def render_projects_html
    lambda do
      init_project_hidden_todo_counts(['project'])
      @page_title = "TRACKS::List Projects"
      @count = current_user.projects.size 
      @active_projects = @projects.select{ |p| p.active? }
      @hidden_projects = @projects.select{ |p| p.hidden? }
      @completed_projects = @projects.select{ |p| p.completed? }
      @no_projects = @projects.empty?
      @projects.cache_note_counts
      @new_project = current_user.projects.build
      render
    end
  end

  def render_rss_feed
    lambda do
      render_rss_feed_for @projects, :feed => feed_options,
        :item => { :title => :name, :description => lambda { |p| summary(p) } }
    end
  end

  def render_atom_feed
    lambda do
      render_atom_feed_for @projects, :feed => feed_options,
        :item => { :description => lambda { |p| summary(p) },
        :title => :name,
        :author => lambda { |p| nil } }
    end
  end
    
  def feed_options
    Project.feed_options(current_user)
  end

  def render_text_feed
    lambda do
      init_project_hidden_todo_counts(['project'])
      render :action => 'index_text', :layout => false, :content_type => Mime::TEXT
    end
  end
        
  def set_project_from_params
    @project = current_user.projects.find_by_params(params)
  end
    
  def set_source_view
    @source_view = params['_source_view'] || 'project'
  end
    
  def default_context_filter
    p = params['project']
    p = params['request']['project'] if p.nil? && params['request']
    p = {} if p.nil?
    default_context_name = p['default_context_name']
    p.delete('default_context_name')

    unless default_context_name.blank?
      default_context = Context.find_or_create_by_name(default_context_name)
      p['default_context_id'] = default_context.id
    end
  end

  def summary(project)
    project_description = ''
    project_description += sanitize(markdown( project.description )) unless project.description.blank?
    project_description += "<p>#{count_undone_todos_phrase(p)}. "
    project_description += "Project is #{project.state}."
    project_description += "</p>"
    project_description
  end

end
