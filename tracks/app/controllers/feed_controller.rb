# Produces an feeds of the next actions, both RSS and plain text
#
class FeedController < ApplicationController

  helper :feed
  model :todo, :context, :project
  session :disabled => true # Prevents session control from interfering with feed

  before_filter :check_token_against_user_word

  def index
  end

  # Builds an RSS feed for the latest 15 items
  # This is fairly basic: it lists the action description as the title
  # and the item context as the description
  #
  def na_feed
    @not_done = @user.todos.collect { |x|  x.done? ? nil:x }.compact.sort! {|x,y| y.created_at <=> x.created_at }
    @headers["Content-Type"] = "text/xml; charset=utf-8"
  end

  # Builds a plain text page listing all the next actions,
  # sorted by context (contexts are sorted by position, as on the home page). 
  # Showing notes doesn't make much sense here so they are omitted.
  # Hidden contexts are also hidden in the text view
  # You can use this with GeekTool to get your next actions
  # on the desktop:
  # curl [url from "TXT" link on todo/list]
  #
  def na_text
    @contexts = @user.contexts.collect { |x| x.hide? ? nil:x }.compact.sort! { |x,y| x.position <=> y.position }
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
