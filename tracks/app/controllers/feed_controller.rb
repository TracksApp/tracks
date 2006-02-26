# Produces an feeds of the next actions, both RSS and plain text
#
class FeedController < ApplicationController

  helper :feed
  model :todo, :context, :project
  session :disabled => true # Prevents session control from interfering with feed

  before_filter :check_token_against_user_word

  def index
  end

  # Build an RSS feed
  def rss
    conditions = '(done = 0)'
    options = {:conditions => conditions}

    limit = @params['limit']
    options[:limit] = limit if limit
    @description = limit ? "Lists the last #{limit} uncompleted next actions" : "Lists uncompleted next actions"
    @title = "Tracks - Next Actions"

    if @params['due']
      due_within = @params['due'].to_i
      due_within_date_s = due_within.days.from_now.strftime("%Y-%m-%d")
      conditions << " AND (due <= '#{due_within_date_s}')"
      @title << " due today" if (due_within == 0)
      @title << " due within a week" if (due_within == 6)
      @description << " with a due date #{due_within_date_s} or earlier"
    end

    context_id = @params['context']
    if context_id
      conditions << " AND (context_id = #{context_id})"
      context = @user.contexts.find(context_id)
      @title << " in #{context.name}"
      @description << " in context '#{context.name}'"
    end

    project_id = @params['project']
    if project_id
      conditions << " AND (project_id = #{project_id})"
      project = @user.projects.find(project_id)
      @title << " for #{project.name}"
      @description << " for project '#{project.name}'"
    end
    
    @todos = @user.todos.find_all_by_done(false, options )
    @headers["Content-Type"] = "text/xml; charset=utf-8"
  end

  # Builds a plain text page listing uncompleted next actions,
  # grouped by context (contexts are sorted by position, as on the home page). 
  # Showing notes doesn't make much sense here so they are omitted.
  # Hidden contexts are also hidden in the text view
  # You can use this with GeekTool to get your next actions
  # on the desktop:
  # curl [url from "TXT" link on todo/list]
  #
  def text
    conditions = '(done = 0)'
    options = {:conditions => conditions}

    limit = @params['limit']
    options[:limit] = limit if limit

    if @params['due']
      due_within = @params['due'].to_i
      due_within_date_s = due_within.days.from_now.strftime("%Y-%m-%d")
      conditions << " AND (due <= '#{due_within_date_s}')"
    end

    context_id = @params['context']
    if context_id
      conditions << " AND (context_id = #{context_id})"
      context = @user.contexts.find(context_id)
      @contexts = [context]
    end

    project_id = @params['project']
    if project_id
      conditions << " AND (project_id = #{project_id})"
      project = @user.projects.find(project_id)
    end
    
    @todos = @user.todos.find_all_by_done(false, options )
    
    if (!@contexts)
      @contexts = @user.contexts.find_all_by_hide(false)
    end
    @headers["Content-Type"] = "text/plain; charset=utf-8"
  end

protected

  # Check whether the token in the URL matches the word in the User's table
  def check_token_against_user_word
    @user = User.find_by_login( @params['name'] )
    unless ( @params['token'] == @user.word)
      render :text => "Sorry, you don't have permission to view this page."
      return false
    end
  end

end
