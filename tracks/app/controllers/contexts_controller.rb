class ContextsController < ApplicationController

  helper :todos

  before_filter :init, :except => [:create, :destroy, :order]
  before_filter :init_todos, :only => :show
  before_filter :check_user_set_context, :only => [:update, :destroy]
  skip_before_filter :login_required, :only => [:index]
  prepend_before_filter :login_or_feed_token_required, :only => [:index]
  session :off, :only => :index, :if => Proc.new { |req| ['rss','atom','txt'].include?(req.parameters[:format]) }

  def index
    respond_to do |format|
      format.html { @page_title = "TRACKS::List Contexts"; render }
      format.xml  { render :xml => @contexts.to_xml( :except => :user_id ) }
      format.rss  &render_contexts_rss_feed
      format.atom &render_contexts_atom_feed
      format.text { render :action => 'index_text', :layout => false, :content_type => Mime::TEXT }
    end
  end
  
  def show
    @page_title = "TRACKS::Context: #{@context.name}"
  end
  
  # Example XML usage: curl -H 'Accept: application/xml' -H 'Content-Type: application/xml'
  #                    -u username:password
  #                    -d '<request><context><name>new context_name</name></context></request>'
  #                    http://our.tracks.host/contexts
  #
  def create
    if params[:format] == 'application/xml' && params['exception']
      render_failure "Expected post format is valid xml like so: <request><context><name>context name</name></context></request>."
      return
    end
    @context = @user.contexts.build
    params_are_invalid = true
    if (params['context'] || (params['request'] && params['request']['context']))
      @context.attributes = params['context'] || params['request']['context']
      params_are_invalid = false
    end
    @saved = @context.save
    @context_not_done_counts = { @context.id => 0 }
    respond_to do |wants|
      wants.js
      wants.xml do
        if @context.new_record? && params_are_invalid
          render_failure "Expected post format is valid xml like so: <request><context><name>context name</name></context></request>."
        elsif @context.new_record?
          render_failure @context.errors.to_xml
        else
          render :xml => @context.to_xml( :except => :user_id )
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
    @context.attributes = params["context"]
    if @context.save
      if params['wants_render']
        render
      else
        render :text => success_text || 'Success'
      end
    else
      notify :warning, "Couldn't update new context"
      render :text => ""
    end
  end

  # Fairly self-explanatory; deletes the context
  # If the context contains actions, you'll get a warning dialogue.
  # If you choose to go ahead, any actions in the context will also be deleted.
  def destroy
    @context.destroy
    respond_to do |format|
      format.js
      format.xml { render :text => "Deleted context #{@context.name}" }
    end
  end

  # Methods for changing the sort order of the contexts in the list
  #
  def order
    params["list-contexts"].each_with_index do |id, position|
      if check_user_matches_context_user(id)
        Context.update(id, :position => position + 1)
      end
    end
    render :nothing => true
  end
  
  protected

    def render_contexts_rss_feed
      lambda do
        render_rss_feed_for @contexts, :feed => Context.feed_options(@user),
                                       :item => { :description => lambda { |c| c.summary(count_undone_todos_phrase(c)) } }
      end
    end

    def render_contexts_atom_feed
      lambda do
        render_atom_feed_for @contexts, :feed => Context.feed_options(@user),
                                        :item => { :description => lambda { |c| c.summary(count_undone_todos_phrase(c)) },
                                                   :author => lambda { |c| nil } }
      end
    end

    def check_user_set_context
      if params['url_friendly_name']
        @context = @user.contexts.find_by_url_friendly_name(params['url_friendly_name'])
      elsif params['id'] && params['id'] =~ /^\d+$/
        @context = @user.contexts.find(params['id'])
      elsif params['id']
        @context = @user.contexts.find_by_url_friendly_name(params['id'])
      else
        redirect_to :action => 'index'
      end
      if @context && @user == @context.user
        return @context
      else
        @context = nil # Should be nil anyway.
        notify :warning, "Item and session user mis-match: #{@context.user_id} and #{@user.id}!"
        render :text => ''
      end
    end

    def check_user_matches_context_user(id)
       @context = Context.find_by_id_and_user_id(id, @user.id)
       if @user == @context.user
         return @context
       else
         @context = nil
         notify :warning, "Project and session user mis-match: #{@context.user_id} and #{@user.id}!"
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
      @source_view = params['_source_view'] || 'context'
      # If we exclude completed projects, then we can't display them in the sidebar
      # if the user sets the preference for them to be shown
      # @projects = @user.projects.reject { |x| x.completed? }
      init_data_for_sidebar
      @todos = @user.todos
      @done = @user.todos.find_in_state(:all, :completed, :order => "todos.completed_at DESC")
    end

    def init_todos
      check_user_set_context
      @done = @context.done_todos
      # @not_done_todos = @context.not_done_todos
      # TODO: Temporarily doing this search manually until I can work out a way
      # to do the same thing using not_done_todos acts_as_todo_container method
      # Hides actions in hidden projects from context.
      @not_done_todos = @context.todos.find(:all, :conditions => ['todos.state = ?', 'active'], :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC", :include => :project)
      @count = @not_done_todos.size
    end

end
