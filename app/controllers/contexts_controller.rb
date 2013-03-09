class ContextsController < ApplicationController

  helper :todos

  before_filter :init, :except => [:index, :create, :destroy, :order]
  before_filter :set_context_from_params, :only => [:update, :destroy]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]

  def index
    @all_contexts = current_user.contexts
    @active_contexts = current_user.contexts.active
    @hidden_contexts = current_user.contexts.hidden
    init_not_done_counts(['context']) unless request.format == :autocomplete

    respond_to do |format|
      format.html &render_contexts_html
      format.m    &render_contexts_mobile
      format.xml  { render :xml => @all_contexts.to_xml( :except => :user_id ) }
      format.rss  do
        @feed_title = 'Tracks Contexts'
        @feed_description = "Lists all the contexts for #{current_user.display_name}"
      end
      format.atom do
        @feed_title = 'Tracks Contexts'
        @feed_description = "Lists all the contexts for #{current_user.display_name}"
      end
      format.text do
        # somehow passing Mime::TEXT using content_type to render does not work
        headers['Content-Type']=Mime::TEXT.to_s
        render :action => 'index', :layout => false, :content_type => Mime::TEXT
      end
      format.autocomplete &render_autocomplete
    end
  end
  
  def show
    set_context_from_params
    
    unless @context.nil?
      @max_completed = current_user.prefs.show_number_completed
      @done = @context.todos.completed.limit(@max_completed).reorder("todos.completed_at DESC, todos.created_at DESC").includes(Todo::DEFAULT_INCLUDES)
      @not_done_todos = @context.todos.active.reorder("todos.due IS NULL, todos.due ASC, todos.created_at ASC").includes(Todo::DEFAULT_INCLUDES)

      @deferred = @context.todos.deferred.includes(Todo::DEFAULT_INCLUDES)
      @pending = @context.todos.pending.includes(Todo::DEFAULT_INCLUDES)
        
      @projects = current_user.projects
      @contexts = current_user.contexts

      @count = @not_done_todos.count + @deferred.count + @pending.count
      @page_title = "TRACKS::Context: #{@context.name}"
      respond_to do |format|
        format.html
        format.m    &render_context_mobile
        format.xml  { render :xml => @context.to_xml( :except => :user_id ) }
      end
    else
      respond_to do |format|
        format.html { render :text => 'Context not found', :status => 404 }
        format.xml  { render :xml => '<error>Context not found</error>', :status => 404 }
      end
    end
  end
  
  def create
    if params[:format] == 'application/xml' && params['exception']
      render_failure "Expected post format is valid xml like so: <context><name>context name</name></context>.", 400
      return
    end
    @context = current_user.contexts.build(params['context'])
    @saved = @context.save
    @context_not_done_counts = { @context.id => 0 }
    respond_to do |format|
      format.js do
        @down_count = current_user.contexts.size
        init_not_done_counts
      end
      format.xml do
        if @context.new_record?
          render_failure @context.errors.to_xml.html_safe, 409
        else
          head :created, :location => context_url(@context)
        end
      end
    end
  end

  # Edit the details of the context
  #
  def update
    params['context'] ||= {}
    success_text = if params['field'] == 'name' && params['value']
      params['context']['id'] = params['id']
      params['context']['name'] = params['value']
    end

    @original_context_hidden = @context.hidden?
    @context.attributes = params["context"]

    @saved = @context.save

    if @saved
      if boolean_param('wants_render')
        @state_changed = (@original_context_hidden != @context.hidden?)
        @new_state = (@context.hidden? ? "hidden" : "active") if @state_changed
        respond_to do |format|
          format.js
        end

        # TODO is this param ever used? is this dead code?

      elsif boolean_param('update_context_name')
        @contexts = current_user.projects
        render :template => 'contexts/update_context_name.js.rjs'
        return
      else
        render :text => success_text || 'Success'
      end
    else
      respond_to do |format|
        format.js
        format.xml {
          if @saved
            render :xml => @context.to_xml( :except => :user_id )
          else
            render :text => "Error on update: #{@context.errors.full_messages.inject("") {|v, e| v + e + " " }}", :status => 409
          end
        }
      end
    end
  end

  def edit
    @context = Context.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  # Fairly self-explanatory; deletes the context If the context contains
  # actions, you'll get a warning dialogue. If you choose to go ahead, any
  # actions in the context will also be deleted.
  def destroy
    # make sure the deleted recurring patterns are removed from associated todos
    @context.recurring_todos.each { |rt| rt.clear_todos_association } unless @context.recurring_todos.nil?

    @context.destroy
    respond_to do |format|
      format.js do
        @down_count = current_user.contexts.size
        update_state_counts
      end
      format.xml { render :text => "Deleted context #{@context.name}" }
    end
  end

  # Methods for changing the sort order of the contexts in the list
  #
  def order
    context_ids = params["container_context"]
    @projects = current_user.contexts.update_positions( context_ids )
    render :nothing => true
  rescue
    notify :error, $!
    redirect_to :action => 'index'
  end

  def done_todos
    @source_view = 'context'
    @context = current_user.contexts.find(params[:id])
    @page_title = t('contexts.completed_tasks_title', :context_name => @context.name)

    @done_today, @done_this_week, @done_this_month = DoneTodos.done_todos_for_container(@context)
    @count = @done_today.size + @done_this_week.size + @done_this_month.size

    render :template => 'todos/done'
  end

  def all_done_todos
    @source_view = 'context'
    @context = current_user.contexts.find(params[:id])
    @page_title = t('contexts.all_completed_tasks_title', :context_name => @context.name)

    @done = @context.todos.completed.paginate :page => params[:page], :per_page => 20, :order => 'completed_at DESC', :include => Todo::DEFAULT_INCLUDES
    @count = @done.size
    render :template => 'todos/all_done'
  end

  protected

  def update_state_counts
    @active_contexts_count = current_user.contexts.active.count
    @hidden_contexts_count = current_user.contexts.hidden.count
    @show_active_contexts = @active_contexts_count > 0
    @show_hidden_contexts = @hidden_contexts_count > 0
  end

  def render_contexts_html
    lambda do
      @page_title = "TRACKS::List Contexts"
      @no_active_contexts = @active_contexts.empty?
      @no_hidden_contexts = @hidden_contexts.empty?
      @active_count = @active_contexts.size
      @hidden_count = @hidden_contexts.size
      @count = @active_count + @hidden_count
      @new_context = current_user.contexts.build

      render
    end
  end

  def render_contexts_mobile
    lambda do
      @page_title = "TRACKS::List Contexts"
      @active_contexts = current_user.contexts.active
      @hidden_contexts = current_user.contexts.hidden
      @down_count = @active_contexts.size + @hidden_contexts.size
      cookies[:mobile_url]= {:value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
      render
    end
  end

  def render_context_mobile
    lambda do
      @page_title = "TRACKS::List actions in "+@context.name
      @not_done = @not_done_todos.select {|t| t.context_id == @context.id }
      @down_count = @not_done.size
      cookies[:mobile_url]= {:value => request.fullpath, :secure => SITE_CONFIG['secure_cookies']}
      @mobile_from_context = @context.id
      render
    end
  end
  
  def render_autocomplete
    lambda do
      render :text => for_autocomplete(current_user.contexts, params[:term])
    end
  end

  def feed_options
    Context.feed_options(current_user)
  end

  def set_context_from_params
    @context = current_user.contexts.find(params[:id])
  rescue
    @context = nil
  end

  def init
    @source_view = params['_source_view'] || 'context'
    init_data_for_sidebar
  end

end
