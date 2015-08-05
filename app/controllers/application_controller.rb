require_dependency "login_system"
require_dependency "tracks/source_view"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include LoginSystem
  helper_method :current_user, :prefs, :format_date

  layout proc{ |controller| controller.mobile? ? "mobile" : "application" }
  # exempt_from_layout /\.js\.erb$/

  before_filter :set_session_expiration
  before_filter :set_time_zone
  before_filter :set_zindex_counter
  before_filter :set_locale
  append_before_filter :set_group_view_by
  prepend_before_filter :login_required
  prepend_before_filter :enable_mobile_content_negotiation

  def set_locale
    locale = params[:locale] # specifying a locale in the request takes precedence
    locale = locale || prefs.locale unless current_user.nil? # otherwise, the locale of the currently logged in user takes over
    locale = locale || request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first if request.env['HTTP_ACCEPT_LANGUAGE']

    if locale && I18n::available_locales.map(&:to_s).include?(locale.to_s)
      I18n.locale = locale
    else
      I18n.locale = I18n.default_locale
    end
  end

  def set_session_expiration
    # http://wiki.rubyonrails.com/rails/show/HowtoChangeSessionOptions
    # If the method is called by the feed controller (which we don't have
    # under session control) or if we checked the box to keep logged in on
    # login don't set the session expiry time.
    return if session.nil? || self.controller_name == 'feed' || session['noexpiry'] == "on"

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

  def render_failure message, status = 404
    render :text => message, :status => status
  end

  # Returns a count of next actions in the given context or project The result
  # is count and a string descriptor, correctly pluralised if there are no
  # actions or multiple actions
  #
  def count_undone_todos_phrase(todos_parent)
    count = count_undone_todos(todos_parent)
    deferred_count = count_deferred_todos(todos_parent)
    if count == 0 && deferred_count > 0
      word = "#{I18n.t('common.deferred')}&nbsp;#{I18n.t('common.actions_midsentence', :count => deferred_count)}"
      return "#{deferred_count.to_s}&nbsp;#{word}".html_safe
    else
      word = I18n.t('common.actions_midsentence', :count => count)
      return "#{count}&nbsp;#{word}".html_safe
    end
  end

  def count_undone_todos(todos_parent)
    if todos_parent.nil?
      count = 0
    elsif (todos_parent.is_a?(Project) && todos_parent.hidden?)
      count = @project_project_hidden_todo_counts[todos_parent.id]
    else
      count = eval "@#{todos_parent.class.to_s.downcase}_not_done_counts[#{todos_parent.id}]"
    end
    count || 0
  end

  def count_deferred_todos(todos_parent)
    return todos_parent.nil? ? 0 : eval("@#{todos_parent.class.to_s.downcase}_deferred_counts[#{todos_parent.id}]") || 0
  end

  # Convert a date object to the format specified in the user's preferences in
  # config/settings.yml
  #
  def format_date(date)
    return prefs.format_date(date)
  end

  def for_autocomplete(coll, substr)
    if substr # protect agains empty request
      filtered = coll.find_all{|item| item.name.downcase.include? substr.downcase}
      json_elems = Array[*filtered.map{ |e| {:id => e.id.to_s, :value => e.name} }].to_json
      return json_elems
    else
      return ""
    end
  end

  def format_dependencies_as_json_for_auto_complete(entries)
    json_elems = Array[*entries.map{ |e| {:value => e.id.to_s, :label => e.specification} }].to_json
    return json_elems
  end

  # Here's the concept behind this "mobile content negotiation" hack: In
  # addition to the main, AJAXy Web UI, Tracks has a lightweight low-feature
  # 'mobile' version designed to be suitable for use from a phone or PDA. It
  # makes some sense that the pages of that mobile version are simply alternate
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

  def handle_unverified_request
    unless request.format=="application/xml"
      super # handle xml http auth via our own login code
    end
  end

  def sanitize(arg)
    ActionController::Base.helpers.sanitize(arg)
  end

  protected

  def admin_login_required
    unless User.find(session['user_id']).is_admin
      render :text => t('errors.user_unauthorized'), :status => 401
      return false
    end
  end

  def redirect_back_or_home
    respond_to do |format|
      format.html { redirect_back_or_default root_url }
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

  def self.cas_enabled?
    Tracks::Config.cas_enabled?
  end

  def cas_enabled?
    self.class.cas_enabled?
  end

  def self.prefered_auth?
    Tracks::Config.prefered_auth?
  end

  def prefered_auth?
    self.class.prefered_auth?
  end

  private

  def parse_date_per_user_prefs( s )
    prefs.parse_date(s)
  end

  def init_data_for_sidebar
    @sidebar = Sidebar.new(current_user)

    init_not_done_counts
    if prefs.show_hidden_projects_in_sidebar
      init_project_hidden_todo_counts(['project'])
    end
  end

  def init_not_done_counts(parents = ['project','context'])
    parents.each do |parent|
      eval("@#{parent}_not_done_counts ||= current_user.todos.active.count_by_group('#{parent}_id')")
      eval("@#{parent}_deferred_counts ||= current_user.todos.deferred.count_by_group('#{parent}_id')")
    end
  end

  def init_project_hidden_todo_counts(parents = ['project','context'])
    parents.each do |parent|
      eval("@#{parent}_project_hidden_todo_counts ||= current_user.todos.active_or_hidden.count_by_group('#{parent}_id')")
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
    @z_index_counter = 500
  end

  def todo_xml_params
    if params[:limit_fields] == 'index'
      return [:only => [:id, :created_at, :updated_at, :completed_at] ]
    else
      return [:except => :user_id, :include => [:tags, :predecessors, :successors] ]
    end
  end

  def all_done_todos_for(object)
    object_name = object.class.name.downcase # context or project
    @source_view = "all_done"
    @page_title = t("#{object_name.pluralize}.all_completed_tasks_title", "#{object_name}_name".to_sym => object.name)

    @done = object.todos.completed.reorder('completed_at DESC').includes(Todo::DEFAULT_INCLUDES).
      paginate(:page => params[:page], :per_page => 20)
    @count = @done.size
    render :template => 'todos/all_done'
  end

  def done_todos_for(object)
    object_name = object.class.name.downcase # context or project
    @source_view = "done"
    eval("@#{object_name} = object")
    @page_title = t("#{object_name.pluralize}.completed_tasks_title", "#{object_name}_name".to_sym => object.name)

    @done_today, @done_rest_of_week, @done_rest_of_month = DoneTodos.done_todos_for_container(object.todos)
    @count = @done_today.size + @done_rest_of_week.size + @done_rest_of_month.size

    render :template => 'todos/done'
  end

  def set_group_view_by
    @group_view_by = params['_group_view_by'] || cookies['group_view_by'] || 'context'
  end

end
