# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.

require_dependency "login_system"
require_dependency "redcloth"
require 'date'

$delete_img = "<img src=\"/images/delete.png\" width=\"10\" height=\"10\" />"
$edit_img = "<img src=\"/images/edit.png\" width=\"10\" height=\"10\" />"
$notes_img = "<img src=\"/images/notes.png\" width=\"10\" height=\"10\" />"
$done_img = "<img src=\"/images/done.png\" width=\"16\" height=\"16\" />"

class ApplicationController < ActionController::Base
    
  helper :application
  include LoginSystem
  
end