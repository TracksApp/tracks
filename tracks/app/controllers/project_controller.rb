class ProjectController < ApplicationController
  
  helper :project
  model :context
  model :todo
  scaffold :project
  
  before_filter :login_required
  caches_action :list, :show
  layout "standard"
  
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
    @project = Project.find(@params["id"])
    @places = Context.find_all
    @page_title = "Project: #{@project.name}"
    @not_done = Todo.find_all( "project_id=#{@project.id} AND done=0", "created DESC" )
	end
	
	
	# Called by a form button
	# Parameters from form fields should be passed to create new project
	#
	def add_project
		project = Project.new
		project.name = @params["new_project"]["name"]

			if project.save
			  flash["confirmation"] = "Succesfully added project"
				redirect_to( :action => "list" )
			else
			  flash["warning"] = "Couldn't add project"
				redirect_to( :action => "list" )
			end
	end
	
	
	# Called by a form button
  # Parameters from form fields should be passed to create new item
	#
	def add_item
		item = Todo.new
		item.attributes = @params["new_item"]
		
		# Convert the date format entered (as set in config/settings.yml)
		# to the mysql format YYYY-MM-DD
		if @params["new_item"]["due"] != ""
		  date_fmt = app_configurations["formats"]["date"]
  		formatted_date = DateTime.strptime(@params["new_item"]["due"], "#{date_fmt}")
  		item.due = formatted_date.strftime("%Y-%m-%d")
  	else
  	  item.due = "0000-00-00"
		end
		
		back_to = item.project_id
   
     if item.save
       flash["confirmation"] = "Successfully added next action to project"
       redirect_to( :controller => "project", :action => "show", :id => "#{back_to}" )
     else
       flash["warning"] = "Couldn't add next action to project"
       redirect_to( :controller => "project", :action => "show", :id => "#{back_to}" )
     end
	end
	
	
	def destroy
	  project = Project.find( @params['id'] )
		if project.destroy
			flash["confirmation"] = "Succesfully deleted project"
			redirect_to( :action => "list" )
		else
			flash["warning"] = "Couldn't delete project"
			redirect_to( :action => "list" )
		end
	end
	
	
	# Toggles the 'done' status of the action
	def toggle_check
	  item = Todo.find( @params['id'] )
		
	 	case item.done
 		  when 0: item.done = 1; item.completed = Time.now()
 			when 1: item.done = 0; item.completed = nil
 		end
		
		if item.save
		  flash["confirmation"] = "Marked next action as completed"
			redirect_to( :action => "list" )
		else
		  flash["warning"] = "Couldn't mark next action as completed"
			redirect_to( :action => "list" )
		end	
	end

end
