class ContextController < ApplicationController
      
  helper :context
  model :project
  model :todo
  
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
    @page_title = "TRACKS::List Contexts"
    @contexts = Context.find(:all, :conditions => nil, :order => "position ASC", :limit => nil )
  end

  # Filter the projects to show just the one passed in the URL
  # e.g. <home>/project/show/<project_name> shows just <project_name>.
  #
  def show
    @context = Context.find_by_name(deurlize(@params["name"]))
    @places = Context.find(:all, :order => "position ASC")
    @projects = Project.find(:all, :order => "position ASC")
    @page_title = "TRACKS::Context: #{@context.name}"
    @not_done = Todo.find(:all, :conditions => "done=0 AND context_id=#{@context.id}", 
                          :order => "due IS NULL, due ASC, created ASC")
    @done = Todo.find(:all, :conditions => "done=1 AND context_id=#{@context.id}", 
                          :order => "completed DESC")  
    @count = Todo.count( "context_id=#{@context.id} AND done=0" )
  end  
  
  # Creates a new context via Ajax helpers
  #
  def new_context
    @context = Context.new(@params['context'])
    if @context.save
      render_partial( 'context_listing', @context )
    else
      flash["warning"] = "Couldn't add new context"
      render_text "#{flash["warning"]}"
    end
  end
  
  # Edit the details of the context
  #    
  def update
    context = Context.find(params[:id])
    context.attributes = @params["context"]
    if context.save
      render_partial 'context_listing', context
    else
      flash["warning"] = "Couldn't update new context"
      render_text ""
    end
  end
  
  # Edit the details of the action in this context
  #  
  def update_action
    @places = Context.find(:all, :order => "position ASC")
    @projects = Project.find(:all, :order => "position ASC")
    action = Todo.find(params[:id])
    action.attributes = @params["item"]
    if action.due?
      action.due = Date.strptime(@params["item"]["due"], DATE_FORMAT)
    else
      action.due = ""
    end    
    
    if action.save
      render_partial 'show_items', action
    else
      flash["warning"] = "Couldn't update the action"
      render_text ""
    end
  end
  
  # Called by a form button
  # Parameters from form fields are passed to create new action
  #
  def add_item
    @projects = Project.find( :all, :order => "position ASC" )
    @places = Context.find( :all, :order => "position ASC" )

    item = Todo.new
    item.attributes = @params["new_item"]

    if item.due?
      item.due = Date.strptime(@params["new_item"]["due"], DATE_FORMAT)
    else
      item.due = ""
    end

     if item.save
       render_partial 'show_items', item
     else
       flash["warning"] = "Couldn't add next action  \"#{item.description}\""
       render_text ""
     end
  end
  
  # Fairly self-explanatory; deletes the context
  # If the context contains actions, you'll get a warning dialogue.
  # If you choose to go ahead, any actions in the context will also be deleted.
  def destroy  
    this_context = Context.find(params[:id])
    if this_context.destroy
      render_text ""
    else
      flash["warning"] = "Couldn't delete context \"#{context.name}\""
      redirect_to( :controller => "context", :action => "list" )
    end
  end

  # Delete a next action in a context
  #
  def destroy_action
    item = Todo.find(params[:id])
    if item.destroy
      render_text ""
    else
      flash["warning"] = "Couldn't delete next action \"#{item.description}\""
      redirect_to :action => "list"
    end
  end

  # Toggles the 'done' status of the action
  #
  def toggle_check
    @places = Context.find(:all, :order => "position ASC")
    @projects = Project.find(:all, :order => "position ASC")
    
    item = Todo.find(params[:id])

    item.toggle!('done')
    render_partial 'show_items', item
  end
  
  # Methods for changing the sort order of the contexts in the list
  #
  def move_up
    line = Context.find(params[:id])
    line.move_higher
    line.save
    redirect_to(:controller => "context", :action => "list")
  end
  
  def move_down
    line = Context.find(params[:id])
    line.move_lower
    line.save
    redirect_to(:controller => "context", :action => "list")
  end
  
  def move_top
    line = Context.find(params[:id])
    line.move_to_top
    line.save
    redirect_to(:controller => "context", :action => "list")
  end
  
  def move_bottom
    line = Context.find(params[:id])
    line.move_to_bottom
    line.save
    redirect_to(:controller => "context", :action => "list" )
  end
  
end
