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
  
  before_filter :set_session_expiration
  before_filter :get_current_user
  
  after_filter :set_charset

  # By default, sets the charset to UTF-8 if it isn't already set
  def set_charset
    @headers["Content-Type"] ||= "text/html; charset=UTF-8" 
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
  
  def redirect_with_notice( message,  options = {})
    options['flash_target'] = 'notice'
    redirect_with_flash message, options      
  end
  
  def redirect_with_flash( message, options )
    flash[options['flash_target']] = message
    options.delete 'flash_target'
    redirect_to options
  end
  
  def redirect_with_warning( message,  options = {})
    options['flash_target'] = 'warning'
    redirect_with_flash message, options      
  end
  
  def render_failure message, status = 404
    render :text => message, :status => status
  end
  
  private
  
  def get_current_user
    @user = User.find(session['user_id']) if session['user_id']
    @prefs = @user.preference unless @user.nil?
  end
  
  def get_admin_user
    @admin = User.find(:first, :conditions => [ "is_admin = ?", true ])
  end
    
  def parse_date_per_user_prefs( s )
    return nil if s == ''
    Chronic.parse(s)
  end
    
  def init_data_for_sidebar
    @projects = @user.projects
    @contexts = @user.contexts
    init_not_done_counts
  end
  
  def init_not_done_counts(parents = ['project','context'])
    parents.each {|parent|
      eval("@#{parent}_not_done_counts = Todo.count(:all,
                                            :conditions => ['user_id = ? and type = ? and done = ?', @user.id, \"Immediate\", false],
                                            :group => :#{parent}_id)")
    }
  end  
  
end
