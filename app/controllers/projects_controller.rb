class ProjectsController < ApplicationController

  helper :application, :todos, :notes
  before_filter :set_source_view
  before_filter :set_project_from_params, :only => [:update, :destroy, :show, :edit, :set_reviewed]
  before_filter :default_context_filter, :only => [:create, :update]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]

  def index
    @source_view = params['_source_view'] || 'project_list'
    if params[:projects_and_actions]
      projects_and_actions
    else
      @contexts = current_user.contexts
      init_not_done_counts(['project'])
      init_project_hidden_todo_counts(['project'])
      if params[:only_active_with_no_next_actions]
        @projects = current_user.projects.active.select { |p| count_undone_todos(p) == 0  }
      else
        @projects = current_user.projects.all
      end
      @new_project = current_user.projects.build
      @active_projects = current_user.projects.active
      @hidden_projects = current_user.projects.hidden
      respond_to do |format|
        format.html  do
          @page_title = t('projects.list_projects')
          @count = current_user.projects.count
          @completed_projects = current_user.projects.completed.limit(10)
          @completed_count = current_user.projects.completed.count
          @no_projects = current_user.projects.empty?
          current_user.projects.cache_note_counts
        end
        format.m     do
          @completed_projects = current_user.projects.completed
          @down_count = @active_projects.size + @hidden_projects.size + @completed_projects.size
          cookies[:mobile_url]= {:value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
        end
        format.xml   { render :xml => @projects.to_xml( :except => :user_id )  }
        format.rss   do
          @feed_title = I18n.t('models.project.feed_title')
          @feed_description = I18n.t('models.project.feed_description', :username => current_user.display_name)
        end
        format.atom  do
          @feed_title = I18n.t('models.project.feed_title')
          @feed_description = I18n.t('models.project.feed_description', :username => current_user.display_name)
        end
        format.text do
          # somehow passing Mime::TEXT using content_type to render does not work
          headers['Content-Type']=Mime::TEXT.to_s
        end
        format.autocomplete do
          projects = current_user.projects.active + current_user.projects.hidden
          render :text => for_autocomplete(projects, params[:term])
        end
      end
    end
  end

  def review
    @source_view = params['_source_view'] || 'review'
    @page_title = t('projects.list_reviews')
    @projects = current_user.projects.all
    @contexts = current_user.contexts.all
    @projects_to_review = current_user.projects.select  {|p| p.needs_review?(current_user)}
    @stalled_projects = current_user.projects.select  {|p| p.stalled?}
    @blocked_projects = current_user.projects.select  {|p| p.blocked?}
    @current_projects = current_user.projects.uncompleted.select  {|p| not(p.needs_review?(current_user))}

    init_not_done_counts(['project'])
    init_project_hidden_todo_counts(['project'])
    current_user.projects.cache_note_counts

    @page_title = t('projects.list_reviews')
    @count = @projects_to_review.count + @blocked_projects.count + @stalled_projects.count + @current_projects.count

    @no_projects = current_user.projects.empty?
    @new_project = current_user.projects.build
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
  end

  def set_reviewed
    @project.last_reviewed = Time.zone.now
    @project.save
    
    case @source_view
    when "project"
      redirect_to :action => 'show'
    when "project_list"
      redirect_to :action => 'index'
    when "review"
      redirect_to :action => 'review'
    else
      redirect_to :action => 'index'
    end
  end

  def projects_and_actions
    @projects = current_user.projects.active
    respond_to do |format|
      format.text  {
        # somehow passing Mime::TEXT using content_type to render does not work
        headers['Content-Type']=Mime::TEXT.to_s
        render :action => 'index_text_projects_and_actions', :layout => false, :content_type => Mime::TEXT
      }
    end
  end

  def show
    @max_completed = current_user.prefs.show_number_completed
    init_data_for_sidebar unless mobile?
    @page_title = t('projects.page_title', :project => @project.name)

    @not_done = @project.todos.active_or_hidden.includes(Todo::DEFAULT_INCLUDES)
    @deferred = @project.todos.deferred.includes(Todo::DEFAULT_INCLUDES)
    @pending = @project.todos.pending.includes(Todo::DEFAULT_INCLUDES)

    @done = {}
    @done = @project.todos.completed.
      reorder("todos.completed_at DESC").
      limit(current_user.prefs.show_number_completed).
      includes(Todo::DEFAULT_INCLUDES) unless current_user.prefs.show_number_completed == 0

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
      format.m     do
        if @project.default_context.nil?
          @project_default_context = t('projects.no_default_context')
        else
          @project_default_context = t('projects.default_context', :context => @project.default_context.name)
        end
        cookies[:mobile_url]= {:value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
        @mobile_from_project = @project.id
      end
      format.xml   do
        render :xml => @project.to_xml(:except => :user_id) { |xml|
          xml.not_done { @not_done.each { |child| child.to_xml(:builder => xml, :skip_instruct => true) } }
          xml.deferred { @deferred.each { |child| child.to_xml(:builder => xml, :skip_instruct => true) } }
          xml.pending { @pending.each { |child| child.to_xml(:builder => xml, :skip_instruct => true) } }
          xml.done { @done.each { |child| child.to_xml(:builder => xml, :skip_instruct => true) } }
        }
      end
    end
  end

  def create
    if params[:format] == 'application/xml' && params['exception']
      render_failure "Expected post format is valid xml like so: <project><name>project name</name></project>.", 400
      return
    end
    @project = current_user.projects.build(params['project'])
    @go_to_project = params['go_to_project']
    @saved = @project.save
    @project_not_done_counts = { @project.id => 0 }
    @active_projects_count = current_user.projects.active.count
    @contexts = current_user.contexts

    respond_to do |format|
      format.js do
        @down_count = current_user.projects.size
        init_not_done_counts
      end
      format.xml do
        if @project.new_record?
          render_failure @project.errors.to_xml.html_safe, 409
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
        @contexts = current_user.contexts
        update_state_counts
        init_data_for_sidebar
        init_project_hidden_todo_counts(['project'])
        
        template = 'projects/update'

      # TODO: are these params ever set? or is this dead code?
      elsif boolean_param('update_status')
        template = 'projects/update_status'
      elsif boolean_param('update_default_context')
        @initial_context_name = @project.default_context.name
        template = 'projects/update_default_context'
      elsif boolean_param('update_default_tags')
        template = 'projects/update_default_tags'
      elsif boolean_param('update_project_name')
        @projects = current_user.projects
        template = 'projects/update_project_name'
      else
        render :text => success_text || 'Success'
        return
      end
    else
      init_data_for_sidebar
      template = 'projects/update'
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
    init_project_hidden_todo_counts(['project']) if @state == 'hidden'
  end

  def actionize
    @state = params['state']
    @projects = current_user.projects.actionize(:state => @state) if @state
    @contexts = current_user.contexts
    init_not_done_counts(['project'])
    init_project_hidden_todo_counts(['project']) if @state == 'hidden'
  end

  def done_todos
    @source_view = 'project'
    @project = current_user.projects.find(params[:id])
    @page_title = t('projects.completed_tasks_title', :project_name => @project.name)

    @done_today, @done_this_week, @done_this_month = DoneTodos.done_todos_for_container(@project)
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
