# Produces an feeds of the next actions, both RSS and plain text
#
class FeedController < ApplicationController
  
  helper :feed
  model :todo, :context, :project
  
  def index
  end
  
  # Builds an RSS feed for the latest 15 items
  # This is fairly basic: it lists the action description as the title
  # and the item context as the description
  #
  def na_feed
    # Check whether the token in the URL matches the word in the User's table
    # Render the RSS feed if it is, or show an error message if not
    @token = @params['token']
    @user_name = @params['name']
    @current_user = User.find_by_login(@user_name)
    if (@token == @current_user.word && @user_name == @current_user.login)
      @not_done = Todo.find_all( "done=0", "created DESC" )
      @headers["Content-Type"] = "text/xml; charset=utf-8"
    else
      render_text "Sorry, you don't have permission to view this page."
    end
  end
  
  # Builds a plain text page listing all the next actions,
  # sorted by context. Showing notes doesn't make much sense here
  # so they are omitted. You can use this with GeekTool to get your next actions
  # on the desktop:
  # curl [url from "TXT" link on todo/list]
  #
  def na_text
    # Check whether the token in the URL matches the word in the User's table
    # Render the text file if it is, or show an error message if not
    @token = @params['token']
    @user_name = @params['name']
    @current_user = User.find_by_login(@user_name)
    if (@token == @current_user.word && @user_name == @current_user.login)
      @places = Context.find_all
      @projects = Project.find_all
      @not_done = Todo.find_all( "done=0", "context_id ASC" )
      @headers["Content-Type"] = "text/plain; charset=utf-8"
    else
      render_text "Sorry, you don't have permission to view this page."
    end
  end
  
end
