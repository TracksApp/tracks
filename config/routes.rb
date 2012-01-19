ActionController::Routing::Routes.draw do |map|
  map.resources :users,
    :member => {:change_password => :get, :update_password => :post,
    :change_auth_type => :get, :update_auth_type => :post, :complete => :get,
    :refresh_token => :post }

  map.with_options :controller => :users do |users|
    users.signup 'signup', :action => "new"
  end

  map.resources :contexts, :collection => {:order => :post, :done => :get}, :member => {:done_todos => :get, :all_done_todos => :get} do |contexts|
    contexts.resources :todos, :name_prefix => "context_"
  end

  map.resources :projects,
    :collection => {:order => :post, :alphabetize => :post, :actionize => :post, :done => :get},
    :member => {:done_todos => :get, :all_done_todos => :get, :set_reviewed => :get} do |projects|
      projects.resources :todos, :name_prefix => "project_"
  end

  map.with_options :controller => :projects do |projects|
    projects.review 'review', :action => :review
  end

  map.resources :notes

  map.resources :todos,
    :member => {:toggle_check => :put, :toggle_star => :put, :defer => :put},
    :collection => {:check_deferred => :post, :filter_to_context => :post, :filter_to_project => :post, :done => :get, :all_done => :get
  }

  map.with_options :controller => :todos do |todos|
    todos.home '', :action => "index"
    todos.tickler 'tickler.:format', :action => "list_deferred"
    todos.mobile_tickler 'tickler.m', :action => "list_deferred", :format => 'm'

    # This route works for tags with dots like /todos/tag/version1.5
    # please note that this pattern consumes everything after /todos/tag
    # so /todos/tag/version1.5.xml will result in :name => 'version1.5.xml'
    # UPDATE: added support for mobile view. All tags ending on .m will be
    # routed to mobile view of tags.
    todos.mobile_tag 'todos/tag/:name.m', :action => "tag", :format => 'm'
    todos.text_tag 'todos/tag/:name.txt', :action => "tag", :format => 'txt'
    todos.tag 'todos/tag/:name', :action => "tag", :name => /.*/
    todos.done_tag 'todos/done/tag/:name', :action => "done_tag"
    todos.all_done_tag 'todos/all_done/tag/:name', :action => "all_done_tag"

    todos.tags 'tags.autocomplete', :action => "tags", :format => 'autocomplete'
    todos.auto_complete_for_predecessor 'auto_complete_for_predecessor', :action => 'auto_complete_for_predecessor'

    todos.calendar 'calendar.ics', :action => "calendar", :format => 'ics'
    todos.calendar 'calendar.xml', :action => "calendar", :format => 'xml'
    todos.calendar 'calendar', :action => "calendar"

    todos.hidden 'hidden.xml', :action => "list_hidden", :format => 'xml'

    todos.mobile 'mobile', :action => "index", :format => 'm'
    todos.mobile_abbrev 'm', :action => "index", :format => 'm'
    todos.mobile_abbrev_new 'm/new', :action => "new", :format => 'm'

    todos.mobile_todo_show_notes 'todos/notes/:id.m', :action => "show_notes", :format => 'm'
    todos.todo_show_notes 'todos/notes/:id', :action => "show_notes"
    todos.done_todos 'todos/done', :action => :done
    todos.all_done_todos 'todos/all_done', :action => :all_done
  end
  map.root :controller => 'todos' # Make OpenID happy because it needs #root_url defined

  map.resources :recurring_todos, :collection => {:done => :get},
    :member => {:toggle_check => :put, :toggle_star => :put}
  map.with_options :controller => :recurring_todos do |rt|
    rt.recurring_todos 'recurring_todos', :action => 'index'
  end

  map.with_options :controller => :login do |login|
    login.login 'login', :action => 'login'
    login.login_cas 'login_cas', :action => 'login_cas'
    login.formatted_login 'login.:format', :action => 'login'
    login.logout 'logout', :action => 'logout'
    login.formatted_logout 'logout.:format', :action => 'logout'
  end

  map.with_options :controller => :feedlist do |fl|
    fl.mobile_feeds 'feeds.m', :action => 'index', :format => 'm'
    fl.feeds        'feeds',   :action => 'index'
  end

  map.with_options :controller => :integrations do |i|
    i.integrations  'integrations', :action => 'index'
    i.rest_api_docs 'integrations/rest_api', :action => "rest_api"
    i.search_plugin 'integrations/search_plugin.xml', :action => 'search_plugin', :format => 'xml'
    i.google_gadget 'integrations/google_gadget.xml', :action => 'google_gadget', :format => 'xml'
    i.cloudmailin   'integrations/cloudmailin', :action => 'cloudmailin'
  end

  map.with_options :controller => :preferences do |p|
    p.preferences 'preferences', :action => 'index'
    p.preferences_date_format 'preferences/render_date_format', :action => 'render_date_format'
  end

  map.with_options :controller => :stats do |stats|
    stats.stats 'stats',  :action => 'index'
    stats.done_overview 'done', :action => 'done'
  end

  map.search 'search', :controller => 'search', :action => 'index'
  map.data 'data', :controller => 'data', :action => 'index'

  Translate::Routes.translation_ui(map) if Rails.env != "production"

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
