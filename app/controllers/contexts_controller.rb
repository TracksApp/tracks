class ContextsController < ApplicationController

  helper :todos

  before_filter :init, :except => [:index, :create, :destroy, :order]
  before_filter :init_todos, :only => :show
  before_filter :set_context_from_params, :only => [:update, :destroy]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]

  def index
    # #true is passed here to force an immediate load so that size and empty?
    # checks later don't result in separate SQL queries
    @active_contexts = current_user.contexts.active(true) 
    @hidden_contexts = current_user.contexts.hidden(true)
    @new_context = current_user.contexts.build

    # save all contexts here as @new_context will add an empty one to current_user.contexts
    @all_contexts = @active_contexts + @hidden_contexts
    @count = @all_contexts.size


    init_not_done_counts(['context'])
    respond_to do |format|
      format.html &render_contexts_html
      format.m    &render_contexts_mobile
      format.xml  { render :xml => @all_contexts.to_xml( :except => :user_id ) }
      format.rss  &render_contexts_rss_feed
      format.atom &render_contexts_atom_feed
      format.text do
        @all_contexts = current_user.contexts.all
        render :action => 'index', :layout => false, :content_type => Mime::TEXT
      end
      format.autocomplete { render :text => for_autocomplete(@active_contexts + @hidden_contexts, params[:term])}
    end
  end
  
  def show
    @contexts = current_user.contexts(true)
    if (@context.nil?)
      respond_to do |format|
        format.html { render :text => 'Context not found', :status => 404 }
        format.xml  { render :xml => '<error>Context not found</error>', :status => 404 }
      end
    else
      @page_title = "TRACKS::Context: #{@context.name}"
      respond_to do |format|
        format.html
        format.m    &render_context_mobile
        format.xml  { render :xml => @context.to_xml( :except => :user_id ) }
      end
    end
  end
  
  # Example XML usage: curl -H 'Accept: application/xml' -H 'Content-Type:
  # application/xml'
  #                    -u username:password
  #                    -d '<request><context><name>new context_name</name></context></request>'
  #                    http://our.tracks.host/contexts
  #
  def create
    if params[:format] == 'application/xml' && params['exception']
      render_failure "Expected post format is valid xml like so: <request><context><name>context name</name></context></request>.", 400
      return
    end
    @context = current_user.contexts.build
    params_are_invalid = true
    if (params['context'] || (params['request'] && params['request']['context']))
      @context.attributes = params['context'] || params['request']['context']
      params_are_invalid = false
    end
    @saved = @context.save
    @context_not_done_counts = { @context.id => 0 }
    respond_to do |format|
      format.js do
        @down_count = current_user.contexts.size
      end
      format.xml do
        if @context.new_record? && params_are_invalid
          render_failure "Expected post format is valid xml like so: <request><context><name>context name</name></context></request>.", 400
        elsif @context.new_record?
          render_failure @context.errors.to_xml, 409
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
      render
    end
  end
  
  def render_contexts_mobile
    lambda do
      @page_title = "TRACKS::List Contexts"
      @active_contexts = current_user.contexts.active
      @hidden_contexts = current_user.contexts.hidden
      @down_count = @active_contexts.size + @hidden_contexts.size 
      cookies[:mobile_url]= {:value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
      render :action => 'index_mobile'
    end
  end
    
  def render_context_mobile
    lambda do
      @page_title = "TRACKS::List actions in "+@context.name
      @not_done = @not_done_todos.select {|t| t.context_id == @context.id } 
      @down_count = @not_done.size 
      cookies[:mobile_url]= {:value => request.request_uri, :secure => SITE_CONFIG['secure_cookies']}
      @mobile_from_context = @context.id
      render :action => 'mobile_show_context'
    end
  end

  def render_contexts_rss_feed
    lambda do
      render_rss_feed_for current_user.contexts.all, :feed => feed_options,
        :item => { :description => lambda { |c| c.summary(count_undone_todos_phrase(c)) } }
    end
  end

  def render_contexts_atom_feed
    lambda do
      render_atom_feed_for current_user.contexts.all, :feed => feed_options,
        :item => { :description => lambda { |c| c.summary(count_undone_todos_phrase(c)) },
        :author => lambda { |c| nil } }
    end
  end
    
  def feed_options
    Context.feed_options(current_user)
  end

  def set_context_from_params
    @context = current_user.contexts.find_by_params(params)
  rescue
    @context = nil
  end
     
  def init
    @source_view = params['_source_view'] || 'context'
    init_data_for_sidebar
  end

  def init_todos
    set_context_from_params
    unless @context.nil?
      @context.todos.send :with_scope, :find => { :include => [:project, :tags] } do
        @done = @context.done_todos
      end

      @max_completed = current_user.prefs.show_number_completed
        
      # @not_done_todos = @context.not_done_todos TODO: Temporarily doing this
      # search manually until I can work out a way to do the same thing using
      # not_done_todos acts_as_todo_container method Hides actions in hidden
      # projects from context.
      @not_done_todos = @context.todos.find(
        :all, 
        :conditions => ['todos.state = ? AND (todos.project_id IS ? OR projects.state = ?)', 'active', nil, 'active'], 
        :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC", 
        :include => [:project, :tags])

      @projects = current_user.projects

      @count = @not_done_todos.size
    end

  end

end
