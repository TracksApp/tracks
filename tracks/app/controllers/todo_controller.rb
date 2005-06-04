class TodoController < ApplicationController
  
  helper :todo
  model :context, :project
  
	before_filter :login_required
  layout "standard"
    
  def index
    list
    render_action "list"
  end

  # Main method for listing tasks
  # Set page title, and fill variables with contexts and done and not-done tasks
  # Number of completed actions to show is determined by a setting in settings.yml
  #
	def list
		@page_title = "TRACKS::List tasks"
		@projects = Project.find( :all, :order => "position ASC" )
		@places = Context.find( :all, :order => "position ASC" )
	  @shown_places = Context.find( :all, :conditions => "hide=0", :order => "position ASC" )
    @hidden_places = Context.find( :all, :conditions => "hide=1", :order => "position ASC" )
		@done = Todo.find( :all, :conditions => "done=1", :order => "completed DESC",
		                  :limit => NO_OF_ACTIONS )
		@av_days_to_completion, @max_days_to_completion = av_completed()
		
		# Set count badge to number of not-done, not hidden context items
		@count = count_shown_items( @hidden_places )
	end


	# List the completed tasks, sorted by completion date
	#
	# Use days declaration? 1.day.ago?
  def completed
    @page_title = "TRACKS::Completed tasks"
	  today_date = Date::today() - 1
    today_query = today_date.strftime("'%Y-%m-%d'") + " <= completed"

	  week_begin = Date::today() - 2
	  week_end = Date::today() - 7

    week_query = week_begin.strftime("'%Y-%m-%d'") + " >= completed 
                  AND " + week_end.strftime("'%Y-%m-%d'") + " <= completed"

	  month_begin = Date::today() - 8
	  month_end = Date::today() - 31

    month_query = month_begin.strftime("'%Y-%m-%d'") + " >= completed 
                  AND " + month_end.strftime("'%Y-%m-%d'") + " <= completed"

    @done_today = Todo.find_by_sql( "SELECT * FROM todos WHERE done = 1 AND #{today_query} 
                  ORDER BY completed DESC;" )
    @done_this_week = Todo.find_by_sql( "SELECT * FROM todos WHERE done = 1 AND #{week_query} 
                  ORDER BY completed DESC;" )
    @done_this_month = Todo.find_by_sql( "SELECT * FROM todos WHERE done = 1 AND #{month_query}     
                  ORDER BY completed DESC;" )
  end
  
  # Archived completed items, older than 31 days
	#
  def completed_archive
    @page_title = "TRACKS::Archived completed tasks"
	  archive_date = Date::today() - 32
    archive_query = archive_date.strftime("'%Y-%m-%d'") + " >= completed"
    @done_archive = Todo.find_by_sql( "SELECT * FROM todos WHERE done = 1 AND #{archive_query} 
                  ORDER BY completed DESC;" )
  end
	
  # Called by a form button
  # Parameters from form fields are passed to create new action
  # in the selected context.
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
	
  # Edit the details of an action
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
	
  # Delete a next action in a context
  #
  def destroy_action
    item = Todo.find(@params['id'])
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
	  @projects = Project.find(:all, :order => "position ASC")
		@places = Context.find(:all, :order => "position ASC")

	  item = Todo.find(@params['id'])

	  item.toggle!('done')
	  render_partial 'show_items', item
	end	
	
end
