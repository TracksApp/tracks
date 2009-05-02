class ProjectsController < ApplicationController

  helper :application, :todos, :notes
  before_filter :set_source_view
  before_filter :set_project_from_params, :only => [:update, :destroy, :show, :edit]
  before_filter :default_context_filter, :only => [:create, :update]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]
  session :off, :only => :index, :if => Proc.new { |req| ['rss','atom','txt'].include?(req.parameters[:format]) }

  def index
    @source_view = params['_source_view'] || 'project_list'
    @projects = current_user.projects
    if params[:projects_and_actions]
      projects_and_actions
    else      
      @contexts = current_user.contexts
      init_not_done_counts(['project'])
      if params[:only_active_with_no_next_actions]
        @projects = current_user.projects.active.select { |p| count_undone_todos(p) == 0 }
      end
      init_project_hidden_todo_counts(['project'])
      respond_to do |format|
        format.html  &render_projects_html
        format.m     &render_projects_mobile
        format.xml   { render :xml => @projects.to_xml( :except => :user_id )  }
        format.rss   &render_rss_feed
        format.atom  &render_atom_feed
        format.text  &render_text_feed
      end
    end
  end

  def projects_and_actions
    @projects = current_user.projects.active
    respond_to do |format|
      format.text  { 
        render :action => 'index_text_projects_and_actions', :layout => false, :content_type => Mime::TEXT
      }
    end
  end

  def show
    @max_completed = current_user.prefs.show_number_completed
    init_data_for_sidebar unless mobile?
    @page_title = "TRACKS::Project: #{@project.name}"
    
    @not_done = @project.not_done_todos_including_hidden
    @deferred = @project.deferred_todos
    @done = @project.todos.find_in_state(:all, :completed, :order => "todos.completed_at DESC", :limit => current_user.prefs.show_number_completed, :include => [:context])

    @count = @not_done.size
    @down_count = @count + @deferred.size 
    @next_project = current_user.projects.next_from(@project)
    @previous_project = current_user.projects.previous_from(@project)
    @default_project_context_name_map = build_default_project_context_name_map(current_user.projects).to_json
    @default_project_tags_map = build_default_project_tags_map(current_user.projects).to_json
    respond_to do |format|
      format.html
      format.m     &render_project_mobile
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
    @active_projects_count = current_user.projects.active.count
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
      @new_state = params['project']['state']
      @state_changed = @project.state != @new_state
      logger.info "@state_changed: #{@project.state} == #{params['project']['state']} != #{@state_changed}"
      params['project'].delete('state')
    end
    success_text = if params['field'] == 'name' && params['value']
      params['project']['id'] = params['id'] 
      params['project']['name'] = params['value'] 
    end
    @project.attributes = params['project']
    if @project.save
      @project.transition_to(@new_state) if @state_changed
      if boolean_param('wants_render')
        if (@project.hidden?)
          @project_project_hidden_todo_counts = Hash.new
          @project_project_hidden_todo_counts[@project.id] = @project.reload().not_done_todos_including_hidden.count
        else
          @project_not_done_counts = Hash.new
          @project_not_done_counts[@project.id] = @project.reload().not_done_todos_including_hidden.count
        end
        @contexts = current_user.contexts
        @active_projects_count = current_user.projects.active.count
        @hidden_projects_count = current_user.projects.hidden.count
        @completed_projects_count = current_user.projects.completed.count
        render :template => 'projects/update.js.rjs'
        return
      elsif boolean_param('update_status')
        render :template => 'projects/update_status.js.rjs'
        return
      elsif boolean_param('update_default_context')
        @initial_context_name = @project.default_context.name 
        render :template => 'projects/update_default_context.js.rjs'
        return
      elsif boolean_param('update_default_tags')
        render :template => 'projects/update_default_tags.js.rjs'
        return
      elsif boolean_param('update_project_name')
        @projects = current_user.projects
        render :template => 'projects/update_project_name.js.rjs'
        return
      else
        render :text => success_text || 'Success'
        return
      end
    else
      notify :warning, "Couldn't update project"
      render :text => ''
      return
    end
    render :template => 'projects/update.js.rjs'
  end
  
  def edit
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @project.destroy
    @active_projects_count = current_user.projects.active.count
    @hidden_projects_count = current_user.projects.hidden.count
    @completed_projects_count = current_user.projects.completed.count
    respond_to do |format|
      format.js { @down_count = current_user.projects.size }
      format.xml { render :text => "Deleted project #{@project.name}" }
    end
  end
  
  def order
    project_ids = params["list-active-projects"] || params["list-hidden-projects"] || params["list-completed-projects"]    
    @projects = current_user.projects.update_positions( project_ids )
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
  
  def actionize
    @state = params['state']
    @projects = current_user.projects.actionize(current_user.id, :state => @state) if @state
    @contexts = current_user.contexts
    init_not_done_counts(['project'])
  end
  
  protected
    
  def render_projects_html
    lambda do
      @page_title = "TRACKS::List Projects"
      @count = current_user.projects.size 
      @active_projects = current_user.projects.active
      @hidden_projects = current_user.projects.hidden
      @completed_projects = current_user.projects.completed
      @no_projects = current_user.projects.empty?
      current_user.projects.cache_note_counts
      @new_project = current_user.projects.build
      render
    end
  end

  def render_projects_mobile
    lambda do
      @active_projects = @projects.active
      @hidden_projects = @projects.hidden
      @completed_projects = @projects.completed
      @down_count = @active_projects.size + @hidden_projects.size + @completed_projects.size 
      cookies[:mobile_url]= {:value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
      render :action => 'index_mobile'
    end
  end
    
  def render_project_mobile
    lambda do
      if @project.default_context.nil?
        @project_default_context = "This project does not have a default context"
      else
        @project_default_context = "The default context for this project is "+
          @project.default_context.name
      end
      cookies[:mobile_url]= {:value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
      @mobile_from_project = @project.id
      render :action => 'project_mobile'
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
      render :action => 'index', :layout => false, :content_type => Mime::TEXT
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