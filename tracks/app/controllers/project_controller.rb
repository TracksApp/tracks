class ProjectController < ApplicationController
  
  helper :project
  model :context
  model :todo
  
  before_filter :login_required
  caches_action :list
  layout "standard"
  
  def index 
    list
    render_action "list"
  end

  # Main method for listing projects
	# Set page title, and collect existing projects in @projects
	#
  def list
		@page_title = "List Projects"
		@projects = Project.find_all
	end
	
	
	# Filter the projects to show just the one passed in the URL
  # e.g. <home>/project/show/<project_id> shows just <project_id>.
  #
	def show
    @project = Project.find_by_name(@params["name"].humanize)
    @places = Context.find_all
    @page_title = "Project: #{@project.name}"
    @not_done = Todo.find_all( "project_id=#{@project.id} AND done=0", "created DESC" )
    @count = Todo.count( "project_id=#{@project.id} AND done=0" )
	end
	
	
	def edit
	  expire_action(:controller => "project", :action => "list")
	  @project = Project.find(@params['id'])
    @page_title = "Edit project: #{@project.name.capitalize}"  
	end
	
	
	def update
    @project = Project.find(@params['project']['id'])
    @project.attributes = @params['project']
    if @project.save
      flash["confirmation"] = "Project \"#{@project.name}\" was successfully updated"
      redirect_to :action => 'list'
    else
      flash["warning"] = "Project \"#{@project.name}\" could not be updated"
      redirect_to :action => 'list'
    end
  end
  
  
	# Called by a form button
	# Parameters from form fields should be passed to create new project
	#
	def add_project
	  expire_action(:controller => "project", :action => "list")
		project = Project.new
		project.name = @params["new_project"]["name"]

			if project.save
				flash["confirmation"] = "Succesfully added project \"#{project.name}\""
				redirect_to( :action => "list" )
			else
				flash["warning"] = "Couldn't add project \"#{project.name}\""
				redirect_to( :action => "list" )
			end
	end

	def new
	  expire_action(:controller => "project", :action => "list")
		project = Project.new
		project.name = @params["new_project"]["name"]

			if project.save
				flash["confirmation"] = "Succesfully added project \"#{project.name}\""
				redirect_to( :action => "list" )
			else
				flash["warning"] = "Couldn't add project \"#{project.name}\""
				redirect_to( :action => "list" )
			end
	end
	
	
	# Called by a form button
  # Parameters from form fields should be passed to create new item
	#
	def add_item
	  expire_action(:controller => "project", :action => "list")
		item = Todo.new
		item.attributes = @params["new_item"]
		
		back_to = item.project_id
   
     if item.save
       flash["confirmation"] = "Successfully added next action \"#{item.description}\" to project"
       redirect_to( :controller => "project", :action => "show", :id => "#{back_to}" )
     else
       flash["warning"] = "Couldn't add next action  \"#{item.description}\" to project"
       redirect_to( :controller => "project", :action => "show", :id => "#{back_to}" )
     end
	end
	
	
	def destroy
	  expire_action(:controller => "project", :action => "list")
	  project = Project.find( @params['id'] )
		if project.destroy
			flash["confirmation"] = "Succesfully deleted project \"#{project.name}\""
			redirect_to( :action => "list" )
		else
			flash["warning"] = "Couldn't delete project \"#{project.name}\""
			redirect_to( :action => "list" )
		end
	end
	

end
