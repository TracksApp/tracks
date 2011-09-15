class ProjectsController < ApplicationController

  helper :application, :todos, :notes
  before_filter :set_source_view
  before_filter :set_project_from_params, :only => [:update, :destroy, :show, :edit]
  before_filter :default_context_filter, :only => [:create, :update]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]

  def index
    @source_view = params['_source_view'] || 'project_list'
    @new_project = current_user.projects.build
    if params[:projects_and_actions]
      projects_and_actions
    else
      @contexts = current_user.contexts.all
      init_not_done_counts(['project'])
      init_project_hidden_todo_counts(['project'])
      if params[:only_active_with_no_next_actions]
        @projects = current_user.projects.active.select { |p| count_undone_todos(p) == 0  }
      else
        @projects = current_user.projects.all
      end
      respond_to do |format|
        format.html  &render_projects_html
        format.m     &render_projects_mobile
        format.xml   { render :xml => @projects.to_xml( :except => :user_id )  }
        format.rss   &render_rss_feed
        format.atom  &render_atom_feed
        format.text  &render_text_feed
        format.autocomplete { render :text => for_autocomplete(current_user.projects.uncompleted, params[:term]) }
      end
    end
  end

  def done
    @source_view = params['_source_view'] || 'project_list'
    @page_title = t('projects.list_completed_projects')

    page = params[:page] || 1
    projects_per_page = 20
    @projects = current_user.projects.completed.paginate :page => page, :per_page => projects_per_page
    @count = @projects.count
    @total = current_user.projects.completed.count
    @no_projects = @projects.empty?

    @range_low = (page.to_i-1) * projects_per_page + 1
    @range_high = @range_low + @projects.size - 1

    init_not_done_counts(['project'])
    render
  end

  def set_reviewed
    template = 'projects/update.js.erb'

    #@source_view = 'project'
    @project = current_user.projects.find(params[:id])

    @project.todos.each do |todo|
      todo.created_at = Time.now
      todo.save
    end
   
    redirect_to :action => 'show'
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
    @page_title = t('projects.page_title', :project => @project.name)

    @not_done = @project.todos.active_or_hidden(:include => Todo::DEFAULT_INCLUDES)
    @deferred = @project.todos.deferred(:include => Todo::DEFAULT_INCLUDES)
    @pending = @project.todos.pending(:include => Todo::DEFAULT_INCLUDES)
    @done = @project.todos.find_in_state(:all, :completed,
      :order => "todos.completed_at DESC", :limit => current_user.prefs.show_number_completed, :include => Todo::DEFAULT_INCLUDES)

    @count = @not_done.size
    @down_count = @count + @deferred.size + @pending.size
    @next_project = current_user.projects.next_from(@project)
    @previous_project = current_user.projects.previous_from(@project)
    @default_tags = @project.default_tags
    @new_note = current_user.notes.new
    @new_note.project_id = @project.id
    @contexts = current_user.contexts
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
          head :created, :location => project_url(@project), :text => @project.id
        end
      end
      format.html {redirect_to :action => 'index'}
    end
  end

  # Edit the details of the project
  #
  def update
    template = ""

    params['project'] ||= {}
    if params['project']['state']
      @new_state = params['project']['state']
      @state_changed = @project.state != @new_state
      params['project'].delete('state')
    end
    success_text = if params['field'] == 'name' && params['value']
      params['project']['id'] = params['id']
      params['project']['name'] = params['value']
    end

    @project.attributes = params['project']
    @saved = @project.save
    if @saved
      @project.transition_to(@new_state) if @state_changed
      if boolean_param('wants_render')
        if (@project.hidden?)
          @project_project_hidden_todo_counts = Hash.new
          @project_project_hidden_todo_counts[@project.id] = @project.reload().todos.active_or_hidden.count
        else
          @project_not_done_counts = Hash.new
          @project_not_done_counts[@project.id] = @project.reload().todos.active_or_hidden.count
        end
        @contexts = current_user.contexts
        update_state_counts
        init_data_for_sidebar

        template = 'projects/update.js.erb'

        # TODO: are these params ever set? or is this dead code?

      elsif boolean_param('update_status')
        template = 'projects/update_status.js.rjs'
      elsif boolean_param('update_default_context')
        @initial_context_name = @project.default_context.name
        template = 'projects/update_default_context.js.rjs'
      elsif boolean_param('update_default_tags')
        template = 'projects/update_default_tags.js.rjs'
      elsif boolean_param('update_project_name')
        @projects = current_user.projects
        template = 'projects/update_project_name.js.rjs'
      else
        render :text => success_text || 'Success'
        return
      end
    else
      init_data_for_sidebar
      template = 'projects/update.js.erb'
    end

    respond_to do |format|
      format.js { render :template => template }
      format.html { redirect_to :action => 'index'}
      format.xml {
        if @saved
          render :xml => @project.to_xml( :except => :user_id )
        else
          render :text => "Error on update: #{@project.errors.full_messages.inject("") {|v, e| v + e + " " }}", :status => 409
        end
      }
    end

  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @project.recurring_todos.each {|rt| rt.remove_from_project!}
    @project.destroy

    respond_to do |format|
      format.js {
        @down_count = current_user.projects.size
        update_state_counts
      }
      format.xml { render :text => "Deleted project #{@project.name}" }
    end
  end

  def order
    project_ids = params["container_project"]
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
    @projects = current_user.projects.actionize(:state => @state) if @state
    @contexts = current_user.contexts
    init_not_done_counts(['project'])
  end

  def done_todos
    @source_view = 'project'
    @project = current_user.projects.find(params[:id])
    @page_title = t('projects.completed_tasks_title', :project_name => @project.name)

    completed_todos = @project.todos.completed

    @done_today = get_done_today(completed_todos)
    @done_this_week = get_done_this_week(completed_todos)
    @done_this_month = get_done_this_month(completed_todos)
    @count = @done_today.size + @done_this_week.size + @done_this_month.size

    render :template => 'todos/done'
  end

  def all_done_todos
    @source_view = 'project'
    @project = current_user.projects.find(params[:id])
    @page_title = t('projects.all_completed_tasks_title', :project_name => @project.name)

    @done = @project.todos.completed.paginate :page => params[:page], :per_page => 20, :order => 'completed_at DESC', :include => Todo::DEFAULT_INCLUDES
    @count = @done.size
    render :template => 'todos/all_done'
  end

  protected

  def update_state_counts
    @active_projects_count = current_user.projects.active.count
    @hidden_projects_count = current_user.projects.hidden.count
    @completed_projects_count = current_user.projects.completed.count
    @show_active_projects = @active_projects_count > 0
    @show_hidden_projects = @hidden_projects_count > 0
    @show_completed_projects = @completed_projects_count > 0
  end

  def render_projects_html
    lambda do
      @page_title = t('projects.list_projects')
      @count = current_user.projects.count
      @active_projects = current_user.projects.active
      @hidden_projects = current_user.projects.hidden
      @completed_projects = current_user.projects.completed.find(:all, :limit => 10)
      @completed_count = current_user.projects.completed.count
      @no_projects = current_user.projects.empty?
      current_user.projects.cache_note_counts
      @new_project = current_user.projects.build
      render
    end
  end

  def render_projects_mobile
    lambda do
      @active_projects = current_user.projects.active
      @hidden_projects = current_user.projects.hidden
      @completed_projects = current_user.projects.completed
      @down_count = @active_projects.size + @hidden_projects.size + @completed_projects.size
      cookies[:mobile_url]= {:value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
      render :action => 'index_mobile'
    end
  end

  def render_project_mobile
    lambda do
      if @project.default_context.nil?
        @project_default_context = t('projects.no_default_context')
      else
        @project_default_context = t('projects.default_context', :context => @project.default_context.name)
      end
      cookies[:mobile_url]= {:value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
      @mobile_from_project = @project.id
      render :action => 'project_mobile'
    end
  end

  def render_rss_feed
    lambda do
      render_rss_feed_for @projects, :feed => feed_options,
        :title => :name,
        :item => { :description => lambda { |p| @template.summary(p) } }
    end
  end

  def render_atom_feed
    lambda do
      render_atom_feed_for @projects, :feed => feed_options,
        :item => { :description => lambda { |p| @template.summary(p) },
        :title => :name,
        :author => lambda { |p| nil } }
    end
  end

  def feed_options
    Project.feed_options(current_user)
  end

  def render_text_feed
    lambda do
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
      default_context = current_user.contexts.find_or_create_by_name(default_context_name)
      p['default_context_id'] = default_context.id
    end
  end

end
