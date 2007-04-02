ActionController::Routing::Routes.draw do |map|
  UJS::routes
  
  # Login Routes
  map.connect 'login', :controller => 'login', :action => 'login' 
  map.connect 'logout', :controller => 'login', :action => 'logout'

  map.resources :users,
                :member => {:change_password => :get, :update_password => :post,
                             :change_auth_type => :get, :update_auth_type => :post, :complete => :get,
                             :refresh_token => :post }
  map.with_options :controller => "users" do |users|
    users.signup 'signup', :action => "new"
  end

  # Context Routes
  map.resources :contexts, :collection => {:order => :post} do |contexts|
    contexts.resources :todos, :name_prefix => "context_"
  end

  # Projects Routes
  map.resources :projects, :collection => {:order => :post} do |projects|
    projects.resources :todos, :name_prefix => "project_"
  end

    # ToDo Routes
  map.resources :todos,
                :member => {:toggle_check => :post},
                :collection => {:check_deferred => :post, :filter_to_context => :post, :filter_to_project => :post}
  map.with_options :controller => "todos" do |todos|
    todos.home '', :action => "index"
    todos.tickler 'tickler', :action => "list_deferred"
    todos.done 'done', :action => "completed"
    todos.done_archive 'done/archive', :action => "completed_archive"
    todos.tag 'todos/tag/:name', :action => "tag"
    todos.mobile 'mobile', :action => "index", :format => 'm'
    todos.mobile_abbrev 'm', :action => "index", :format => 'm'
    todos.mobile_abbrev_new 'm/new', :action => "new", :format => 'm'
  end
  
  # Notes Routes
  map.resources :notes

  # Feed Routes
  map.connect 'feeds', :controller => 'feedlist', :action => 'index'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
