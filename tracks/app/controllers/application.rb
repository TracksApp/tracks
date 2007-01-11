# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.

require_dependency "login_system"
require_dependency "source_view"
require "redcloth"

require 'date'
require 'time'

class ApplicationController < ActionController::Base

  helper :application
  include LoginSystem
  
  layout 'standard'
  
  before_filter :set_session_expiration
  prepend_before_filter :login_required
  
  after_filter :set_charset

  # By default, sets the charset to UTF-8 if it isn't already set
  def set_charset
    headers["Content-Type"] ||= "text/html; charset=UTF-8" 
  end

  def set_session_expiration
    # http://wiki.rubyonrails.com/rails/show/HowtoChangeSessionOptions
    unless session == nil
      return if @controller_name == 'feed' or session['noexpiry'] == "on"
      # If the method is called by the feed controller (which we don't have under session control)
      # or if we checked the box to keep logged in on login
      # don't set the session expiry time.
      if session
        # Get expiry time (allow ten seconds window for the case where we have none)
        expiry_time = session['expiry_time'] || Time.now + 10
        if expiry_time < Time.now
          # Too late, matey...  bang goes your session!
          reset_session
        else
          # Okay, you get another hour
          session['expiry_time'] = Time.now + (60*60)
        end
      end
    end
  end
  
  def render_failure message, status = 404
    render :text => message, :status => status
  end
  
  def rescue_action(exception)
    log_error(exception) if logger
    respond_to do |wants|
      wants.html do
        notify :warning, "An error occurred on the server."
        render :action => "index"
      end
      wants.js { render :action => 'error' }
      wants.xml { render :text => 'An error occurred on the server.' + $! }
    end
  end
  
  private
        
  def parse_date_per_user_prefs( s )
    return nil if s.blank?
    @user.prefs.tz.unadjust(Date.strptime(s, @user.prefs.date_format)).utc.to_date
  end
    
  def init_data_for_sidebar
    @projects = @user.projects
    @contexts = @user.contexts
    init_not_done_counts
    if @prefs.show_hidden_projects_in_sidebar
      init_project_hidden_todo_counts(['project'])
    end
  end
  
  def init_not_done_counts(parents = ['project','context'])
    parents.each do |parent|
      eval("@#{parent}_not_done_counts = Todo.count(:conditions => ['user_id = ? and state = ?', @user.id, 'active'], :group => :#{parent}_id)")
    end
  end
  
  def init_project_hidden_todo_counts(parents = ['project','context'])
    parents.each do |parent|
      eval("@#{parent}_project_hidden_todo_counts = Todo.count(:conditions => ['user_id = ? and state = ?', @user.id, 'project_hidden'], :group => :#{parent}_id)")
    end
  end
  
  # Set the contents of the flash message from a controller
  # Usage: notify :warning, "This is the message"
  # Sets the flash of type 'warning' to "This is the message"
  def notify(type, message)
    flash[type] = message
    logger.error("ERROR: #{message}") if type == :error
  end
  
end
