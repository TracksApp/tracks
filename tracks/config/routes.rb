ActionController::Routing::Routes.draw do |map|
  
  # Mobile/lite version
  map.connect 'mobile', :controller => 'mobile', :action => 'index'
  map.connect 'mobile/add_action', :controller => 'mobile', :action => 'show_add_form'

  # Login Routes
  map.connect 'login', :controller => 'login', :action => 'login' 
  map.connect 'logout', :controller => 'login', :action => 'logout'

  map.resources :users,
                :member => {:change_password => :get, :update_password => :post,
                             :change_auth_type => :get, :update_auth_type => :post,
                             :refresh_token => :post }
 map.with_options :controller => "users" do |users|
   users.signup 'signup', :action => "new"
 end

  # ToDo Routes
  map.resources :todos,
                :member => {:toggle_check => :post},
                :collection => {:check_deferred => :post}
  map.with_options :controller => "todos" do |todos|
    todos.home '', :action => "index"
    todos.tickler 'tickler', :action => "list_deferred"
    todos.done 'done', :action => "completed"
    todos.done_archive 'done/archive', :action => "completed_archive"
    todos.tag 'todos/tag/:name', :action => "tag"
  end

  # Context Routes
  map.resources :contexts, :collection => {:order => :post} 
  map.connect 'context/:context/feed/:action/:login/:token', :controller => 'feed'
  map.connect 'contexts/feed/:feedtype/:login/:token', :controller => 'feed', :action => 'list_contexts_only'

  # Projects Routes
  map.resources :projects, :collection => {:order => :post} 
  map.connect 'project/:project/feed/:action/:login/:token', :controller => 'feed'

  # Notes Routes
  map.resources :notes

  # Feed Routes
  map.connect 'feeds', :controller => 'feedlist', :action => 'index'
  map.connect 'feed/:action/:login/:token', :controller => 'feed'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
