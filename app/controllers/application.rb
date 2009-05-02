# The filters added to this controller will be run for all controllers in the
# application. Likewise will all the methods added be available for all
# controllers.

require_dependency "login_system"
require_dependency "tracks/source_view"
require "redcloth"

require 'date'
require 'time'

# Commented the following line because of #744. It prevented rake db:migrate to
# run because this tag went looking for the taggings table that did not exist
# when you feshly create a new database Old comment: We need this in development
# mode, or you get 'method missing' errors
#
# Tag

class CannotAccessContext < RuntimeError; end

class ApplicationController < ActionController::Base

  protect_from_forgery :secret => SITE_CONFIG['salt']

  helper :application
  include LoginSystem
  helper_method :current_user, :prefs

  layout proc{ |controller| controller.mobile? ? "mobile" : "standard" }
  
  before_filter :set_session_expiration
  before_filter :set_time_zone
  before_filter :set_zindex_counter
  prepend_before_filter :login_required
  prepend_before_filter :enable_mobile_content_negotiation
  after_filter :set_charset

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  helper_method :format_date, :markdown

  # By default, sets the charset to UTF-8 if it isn't already set
  def set_charset
    headers["Content-Type"] ||= "text/html; charset=UTF-8" 
  end
  
  def set_session_expiration
    # http://wiki.rubyonrails.com/rails/show/HowtoChangeSessionOptions
    unless session == nil
      return if @controller_name == 'feed' or session['noexpiry'] == "on"
      # If the method is called by the feed controller (which we don't have
      # under session control) or if we checked the box to keep logged in on
      # login don't set the session expiry time.
      if session
        # Get expiry time (allow ten seconds window for the case where we have
        # none)
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
  
  # def rescue_action(exception)
  #   log_error(exception) if logger
  #   respond_to do |format|
  #     format.html do
  #       notify :warning, "An error occurred on the server."
  #       render :action => "index"
  #     end
  #     format.js { render :action => 'error' }
  #     format.xml { render :text => 'An error occurred on the server.' + $! }
  #   end
  # end
  
  # Returns a count of next actions in the given context or project The result
  # is count and a string descriptor, correctly pluralised if there are no
  # actions or multiple actions
  #
  def count_undone_todos_phrase(todos_parent, string="actions")
    count = count_undone_todos(todos_parent)
    if count == 1
      word = string.singularize
    else
      word = string.pluralize
    end
    return count.to_s + "&nbsp;" + word
  end
  
  def count_undone_todos(todos_parent)
    if todos_parent.nil?
      count = 0
    elsif (todos_parent.is_a?(Project) && todos_parent.hidden?)
      count = eval "@project_project_hidden_todo_counts[#{todos_parent.id}]"
    else
      count = eval "@#{todos_parent.class.to_s.downcase}_not_done_counts[#{todos_parent.id}]"
    end
    count || 0
  end

  # Convert a date object to the format specified in the user's preferences in
  # config/settings.yml
  #
  def format_date(date)
    if date
      date_format = prefs.date_format
      formatted_date = date.in_time_zone(prefs.time_zone).strftime("#{date_format}")
    else
      formatted_date = ''
    end
    formatted_date
  end

  # Uses RedCloth to transform text using either Textile or Markdown Need to
  # require redcloth above RedCloth 3.0 or greater is needed to use Markdown,
  # otherwise it only handles Textile
  #
  def markdown(text)
    RedCloth.new(text).to_html
  end
  
  def build_default_project_context_name_map(projects)
    Hash[*projects.reject{ |p| p.default_context.nil? }.map{ |p| [p.name, p.default_context.name] }.flatten].to_json 
  end
  
  def build_default_project_tags_map(projects)
    Hash[*projects.reject{ |p| p.default_tags.nil? }.map{ |p| [p.name, p.default_tags] }.flatten].to_json 
  end
  
  # Here's the concept behind this "mobile content negotiation" hack: In
  # addition to the main, AJAXy Web UI, Tracks has a lightweight low-feature
  # 'mobile' version designed to be suitablef or use from a phone or PDA. It
  # makes some sense that tne pages of that mobile version are simply alternate
  # representations of the same Todo resources. The implementation goal was to
  # treat mobile as another format and be able to use respond_to to render both
  # versions. Unfortunately, I ran into a lot of trouble simply registering a
  # new mime type 'text/html' with format :m because :html already is linked to
  # that mime type and the new registration was forcing all html requests to be
  # rendered in the mobile view. The before_filter and after_filter hackery
  # below accomplishs that implementation goal by using a 'fake' mime type
  # during the processing and then setting it to 'text/html' in an
  # 'after_filter' -LKM 2007-04-01
  def mobile?
    return params[:format] == 'm'
  end

  def enable_mobile_content_negotiation
    if mobile?
      request.format = :m
    end
  end

  def create_todo_from_recurring_todo(rt, date=nil)
    # create todo and initialize with data from recurring_todo rt
    todo = current_user.todos.build( { :description => rt.description, :notes => rt.notes, :project_id => rt.project_id, :context_id => rt.context_id})
    
    # set dates
    todo.recurring_todo_id = rt.id
    todo.due = rt.get_due_date(date)
    
    show_from_date = rt.get_show_from_date(date)
    if show_from_date.nil?
      todo.show_from=nil
    else
      # make sure that show_from is not in the past
      todo.show_from = show_from_date < Time.zone.now ? nil : show_from_date
    end
    
    saved = todo.save
    if saved
      todo.tag_with(rt.tag_list)
      todo.tags.reload 
    end

    # increate number of occurences created from recurring todo
    rt.inc_occurences
    
    # mark recurring todo complete if there are no next actions left
    checkdate = todo.due.nil? ? todo.show_from : todo.due
    rt.toggle_completion! unless rt.has_next_todo(checkdate)
    
    return saved ? todo : nil
  end
     
  protected
  
  def admin_login_required
    unless User.find_by_id_and_is_admin(session['user_id'], true)
      render :text => "401 Unauthorized: Only admin users are allowed access to this function.", :status => 401
      return false
    end
  end
  
  def redirect_back_or_home
    respond_to do |format|
      format.html { redirect_back_or_default home_url }
      format.m { redirect_back_or_default mobile_url }
    end
  end
  
  def boolean_param(param_name)
    return false if param_name.blank?
    s = params[param_name]
    return false if s.blank? || s == false || s =~ /^false$/i
    return true if s == true || s =~ /^true$/i
    raise ArgumentError.new("invalid value for Boolean: \"#{s}\"")
  end
  
  def self.openid_enabled?
    Tracks::Config.openid_enabled?
  end
  
  def openid_enabled?
    self.class.openid_enabled?
  end

  private
        
  def parse_date_per_user_prefs( s )
    prefs.parse_date(s)
  end
    
  def init_data_for_sidebar
    @completed_projects = current_user.projects.completed
    @hidden_projects = current_user.projects.hidden
    @active_projects = current_user.projects.active

    @active_contexts = current_user.contexts.active
    @hidden_contexts = current_user.contexts.hidden

    init_not_done_counts
    if prefs.show_hidden_projects_in_sidebar
      init_project_hidden_todo_counts(['project'])
    end
  end
  
  def init_not_done_counts(parents = ['project','context'])
    parents.each do |parent|
      eval("@#{parent}_not_done_counts = @#{parent}_not_done_counts || current_user.todos.active.count(:group => :#{parent}_id)")
    end
  end
  
  def init_project_hidden_todo_counts(parents = ['project','context'])
    parents.each do |parent|
      eval("@#{parent}_project_hidden_todo_counts = @#{parent}_project_hidden_todo_counts || current_user.todos.count(:conditions => ['state = ? or state = ?', 'project_hidden', 'active'], :group => :#{parent}_id)")
    end
  end  
  
  # Set the contents of the flash message from a controller Usage: notify
  # :warning, "This is the message" Sets the flash of type 'warning' to "This is
  # the message"
  def notify(type, message)
    flash[type] = message
    logger.error("ERROR: #{message}") if type == :error
  end
  
  def set_time_zone
    Time.zone = current_user.prefs.time_zone if logged_in?
  end

  def set_zindex_counter
    # this counter can be used to handle the IE z-index bug
    @z_index_counter = 1000
  end
  
end
