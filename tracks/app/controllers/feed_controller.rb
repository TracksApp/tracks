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
    prepare_for_feed
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
    prepare_for_feed
    if @params.key?('context')
      @contexts = [ @user.contexts.find(@params['context']) ]
    else    
      @contexts = @user.contexts.find_all_by_hide(false, "position ASC")
    end
    @headers["Content-Type"] = "text/plain; charset=utf-8"
  end
  
  # Builds an iCal compatible export of uncompleted todos
  # so that each action forms a VTODO in your iCal calendar.
  # Due dates are supported, and notes are included.
  #
  def ical
    prepare_for_feed
    if @params.key?('context')
      @contexts = [ @user.contexts.find(@params['context']) ]
    else    
      @contexts = @user.contexts.find_all_by_hide(false, "position ASC")
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

  def prepare_for_feed
    condition_builder = FindConditionBuilder.new
    options = Hash.new
  
    condition_builder.add 'todos.done = ?', false
  
    if @params.key?('limit')
      options[:limit] = limit = @params['limit']
      @description = limit ? "Lists the last #{limit} uncompleted next actions" : "Lists uncompleted next actions"
    end
    @title = "Tracks - Next Actions"
    @description = "Filter: "
  
    if @params.key?('due')
      due_within = @params['due'].to_i
      condition_builder.add('todos.due <= ?', due_within.days.from_now)
      due_within_date_s = due_within.days.from_now.strftime("%Y-%m-%d")
      @title << " due today" if (due_within == 0)
      @title << " due within a week" if (due_within == 6)
      @description << " with a due date #{due_within_date_s} or earlier"
    end
    
    if @params.key?('context')
      context = @user.contexts.find(@params['context'])
      condition_builder.add('todos.context_id = ?', context.id)
      @title << " in #{context.name}"
      @description << " in context '#{context.name}'"
    end
    
    if @params.key?('project')
      project = @user.projects.find(@params['project'])
      condition_builder.add('todos.project_id = ?', project.id)
      @title << " for #{project.name}"
      @description << " for project '#{project.name}'"
    end
  
    options[:conditions] = condition_builder.to_conditions
    options[:include] = :project
    
    @todos = @user.todos.find(:all, options )
    
  end
  
  class FindConditionBuilder
    
    def initialize
      @queries = Array.new
      @params = Array.new
    end
    
    def add(query, param)
       @queries << query
       @params << param
    end
    
    def to_conditions
      [@queries.join(' AND ')] + @params
    end
  end
  
  
end
