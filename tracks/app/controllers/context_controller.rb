class ContextController < ApplicationController
  
    
  helper :context
  model :project
  before_filter :login_required
  caches_action :list
  layout "standard"
  
  
  # Main method for listing contexts
	# Set page title, and collect existing contexts in @contexts
	#

  def index
    list
    render_action "list"
  end

  def list
		@page_title = "TRACKS::List Contexts"
		@contexts = Context.find_all( conditions = nil, "position ASC", limit = nil )
	end
	
	
	# Called by a form button
	# Parameters from form fields should be passed to create new context
	#
	def add_context
	  expire_action(:controller => "context", :action => "list")
		context = Context.new
		context.attributes = @params["new_context"]

			if context.save
				flash["confirmation"] = "Succesfully created context \"#{context.name}\""
				redirect_to( :action => "list" )
			else
				flash["warning"] = "Couldn't add new context \"#{context.name}\""
				redirect_to( :action => "list" )
			end
	end

	def new
	  expire_action(:controller => "context", :action => "list")
		context = Context.new
		context.attributes = @params["new_context"]

			if context.save
				flash["confirmation"] = "Succesfully created context \"#{context.name}\""
				redirect_to( :action => "list" )
			else
				flash["warning"] = "Couldn't add new context \"#{context.name}\""
				redirect_to( :action => "list" )
			end
	end
	
	def edit
	  expire_action(:controller => "context", :action => "list")
	  @context = Context.find(@params['id'])
    @page_title = "TRACKS::Edit context: #{@context.name.capitalize}"  
	end
	
	
	def update
    @context = Context.find(@params['context']['id'])
    @context.attributes = @params['context']
    if @context.save
      flash["confirmation"] = "Context \"#{@context.name}\" was successfully updated"
      redirect_to :action => 'list'
    else
      flash["warning"] = "Context \"#{@context.name}\" could not be updated"
      redirect_to :action => 'list'
    end
  end
  

	# Filter the contexts to show just the one passed in the URL
  # e.g. <home>/context/show/<context_name> shows just <context_name>.
  #
	def show
	  @context = Context.find_by_name(@params["id"].humanize)
	  @projects = Project.find_all
	  @page_title = "TRACKS::Context: #{@context.name.capitalize}"
    @not_done = Todo.find_all( "context_id=#{@context.id} AND done=0", "due DESC, created ASC" )	
    @count = Todo.count( "context_id=#{@context.id} AND done=0" )
  end
  
  
  # Called by a form button
	# Parameters from form fields are passed to create new action
	# in the selected context.
  def add_item
    expire_action(:controller => "context", :action => "list")
		item = Todo.new
		item.attributes = @params["new_item"]
		# where = Context.find_by_id(item.context_id)
		
		back_to = urlize(where.name)
   
     if item.save
       flash["confirmation"] = "Succesfully added action \"#{item.description}\" to context"
       redirect_to( :controller => "context", :action => "show", :name => "#{back_to}")
     else
       flash["warning"] = "Could not add action \"#{item.description}\" to context"
       redirect_to( :controller => "context", :action => "show", :name => "#{back_to}" )
     end
	end
	
	
	# Fairly self-explanatory; deletes the context
	# If the context contains actions, you'll get a warning dialogue.
	# If you choose to go ahead, any actions in the context will also be deleted.
	def destroy
	  expire_action(:controller => "context", :action => "list")
	  context = Context.find( @params['id'] )
		if context.destroy
			flash["confirmation"] = "Succesfully deleted context \"#{context.name}\""
			redirect_to( :action => "list" )
		else
			flash["warning"] = "Couldn't delete context \"#{context.name}\""
			redirect_to( :action => "list" )
		end
	end
	
	
end
