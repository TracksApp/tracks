class ContextController < ApplicationController

  helper :todo

  before_filter :login_required
  layout "standard"

  def index
    list
    render_action "list"
  end

  # Main method for listing contexts
  # Set page title, and collect existing contexts in @contexts
  #
  def list
    self.init
    @page_title = "TRACKS::List Contexts"
  end

  # Filter the projects to show just the one passed in the URL
  # e.g. <home>/project/show/<project_name> shows just <project_name>.
  #
  def show
    init
    init_todos
    @page_title = "TRACKS::Context: #{@context.name}"
  end
  
  # Creates a new context via Ajax helpers
  #
  def new_context
    context = @session['user'].contexts.build
    context.attributes = @params['context']
    context.name = deurlize(context.name)

    if context.save
      render :partial => 'context_listing', :locals => { :context_listing => context }
    else
      flash["warning"] = "Couldn't add new context"
      render :text => "#{flash["warning"]}"
    end
  end

  # Edit the details of the context
  #
  def update
    check_user_set_context
    @context.attributes = @params["context"]
    @context.name = deurlize(@context.name)
    if @context.save
      render_partial 'context_listing', @context
    else
      flash["warning"] = "Couldn't update new context"
      render :text => ""
    end
  end

  # Fairly self-explanatory; deletes the context
  # If the context contains actions, you'll get a warning dialogue.
  # If you choose to go ahead, any actions in the context will also be deleted.
  def destroy
    check_user_set_context
    if @context.destroy
      render_text ""
    else
      flash["warning"] = "Couldn't delete context \"#{@context.name}\""
      redirect_to( :controller => "context", :action => "list" )
    end
  end

  # Methods for changing the sort order of the contexts in the list
  #
  def order
    @params["list-contexts"].each_with_index do |id, position|
      if check_user_matches_context_user(id)
        Context.update(id, :position => position + 1)
      end
    end
    render :nothing => true
  end
  
  protected

    def check_user_set_context
      @user = @session['user']
      if @params["name"]
        @context = Context.find_by_name_and_user_id(deurlize(@params["name"]), @user.id)
      elsif @params['id']
        @context = Context.find_by_id_and_user_id(@params["id"], @user.id)
      else
        redirect_to(:controller => "context", :action => "list" )
      end
      if @user == @context.user
        return @context
      else
        @context = nil # Should be nil anyway.
        flash["warning"] = "Item and session user mis-match: #{@context.user_id} and #{@session['user'].id}!"
        render_text ""
      end
    end

    def check_user_matches_context_user(id)
       @user = @session['user']
       @context = Context.find_by_id_and_user_id(id, @user.id)
       if @user == @context.user
         return @context
       else
         @context = nil
         flash["warning"] = "Project and session user mis-match: #{@context.user_id} and #{@session['user'].id}!"
         render_text ""
       end
    end
     
    def init
      @user = @session['user']
      @projects = @user.projects.collect { |x| x.done? ? nil:x }.compact
      @contexts = @user.contexts
    end

    def init_todos
      check_user_set_context
      @done = @context.find_done_todos
      @not_done = @context.find_not_done_todos
      @count = @not_done.size
    end

end
