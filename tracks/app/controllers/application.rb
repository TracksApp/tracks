# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.

require_dependency "login_system"
require 'date'

$notes_img = "<img src=\"/images/notes.png\" width=\"10\" height=\"10\" border=\"0\" />"
$done_img = "<img src=\"/images/done.png\" width=\"16\" height=\"16\" border=\"0\" />"

class ApplicationController < ActionController::Base
    
  helper :application
  include LoginSystem
  
  def count_shown_items(hidden)
		count = 0
	  sub = 0
	  hidden.each do |h|
	    sub = Todo.find_all("done=0 AND context_id=#{h.id}").length + sub
	  end
	  total = Todo.find_all("done=0").length - sub
  end

end