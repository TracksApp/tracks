# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.

require_dependency "login_system"
require "redcloth"

require 'date'
require 'time'

class ApplicationController < ActionController::Base

  helper :application
  include LoginSystem
  
  before_filter :set_session_expiration
  before_filter :get_current_user
  
  after_filter :set_charset

  # By default, sets the charset to UTF-8 if it isn't already set
  def set_charset
    @headers["Content-Type"] ||= "text/html; charset=UTF-8" 
  end

  # Count the number of uncompleted actions, excluding those 
  # in hidden contexts
  #
  def count_shown_items(hidden)
   count = 0
   sub = 0
   hidden.each do |h|
     sub = Todo.find_all(["done = ? AND context_id= ?", false, h.id]).length + sub
   end
   total = Todo.find_all(["done = ?",false]).length - sub
  end
  
  # Reverses the urlize() method by substituting underscores for spaces
  #
  def deurlize(name)
    name.to_s.gsub(/_/, " ")
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
  
  private
  
  def get_current_user
    @user = User.find(session['user_id']) if session['user_id'] 
  end
  
  def get_admin_user
    @admin = User.find(:first, :conditions => [ "is_admin = ?", true ])
  end
  
end
