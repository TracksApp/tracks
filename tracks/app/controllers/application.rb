# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.

require_dependency "login_system"

require 'date'

class ApplicationController < ActionController::Base

  helper :application
  include LoginSystem

  before_filter :set_session_expiration

  # Contstants from settings.yml
  #
  DATE_FORMAT = app_configurations["formats"]["date"]
  WEEK_STARTS_ON = app_configurations["formats"]["week_starts"]
  NO_OF_ACTIONS = app_configurations["formats"]["hp_completed"]
  STALENESS_STARTS = app_configurations["formats"]["staleness_starts"]

  # Count the number of uncompleted actions, excluding those in hidden contexts
  #
  def count_shown_items(hidden)
   count = 0
   sub = 0
   hidden.each do |h|
     sub = Todo.find_all("done=0 AND context_id=#{h.id}").length + sub
   end
   total = Todo.find_all("done=0").length - sub
  end

  # Returns all the errors on the page for an object...
  #
  def errors_for( obj )
    error_messages_for( obj ) unless instance_eval("@#{obj}").nil?
  end

  # Reverses the urlize() method by substituting underscores for spaces
  #
  def deurlize(name)
    name.to_s.gsub(/_/, " ")
  end

  def set_session_expiration
    # http://wiki.rubyonrails.com/rails/show/HowtoChangeSessionOptions
    return if @controller_name == 'feed'
    # If no session we don't care
    if @session
      # Get expiry time (allow ten seconds window for the case where we have none)
      expiry_time = @session['expiry_time'] || Time.now + 10
      if expiry_time < Time.now
        # Too late, matey...  bang goes your session!
        reset_session
      else
        # Okay, you get another hour
        @session['expiry_time'] = Time.now + (60*60)
      end
    end
  end
  
end
