# Produces an feeds of the next actions, both RSS and plain text
#
class FeedController < ApplicationController
  
  helper :feed
  model :todo, :context, :project
  before_filter :login_required
  
  def index
  end
  
  # Builds an RSS feed for the latest 15 items
  # This is fairly basic: it lists the action description as the title
  # and the item context as the description
  #
  def na_feed
		@not_done = Todo.find_all( "done=0", "created DESC" )
    @headers["Content-Type"] = "text/xml; charset=utf-8"
  end
  
  # Builds a plain text page listing all the next actions,
  # sorted by context. Showing notes doesn' make much sense here
  # so they are omitted. You can use this with GeekTool to get your next actions
  # on the desktop:
  # curl http://url_for_the_app/feed/na_text
  #
  def na_text
    @places = Context.find_all
    @projects = Project.find_all
    @not_done = Todo.find_all( "done=0", "context_id ASC" )
    @headers["Content-Type"] = "text/plain; charset=utf-8"
  end
  
end
