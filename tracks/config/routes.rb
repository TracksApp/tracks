ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'
  

  # Admin Routes
  map.connect 'admin', :controller => 'admin', :action => 'index'
  map.connect 'admin/destroy/:id', :controller => 'admin', :action => 'destroy', :requirements => {:id => /\d+/}

  # Mobile/lite version
  map.connect 'mobile', :controller => 'mobile', :action => 'index'
  map.connect 'mobile/add_action', :controller => 'mobile', :action => 'show_add_form'

  # Login Routes
  map.connect 'login', :controller => 'login', :action => 'login' 
  map.connect 'logout', :controller => 'login', :action => 'logout'
  map.connect 'signup', :controller => 'login', :action => 'signup'

  # ToDo Routes
  map.resources :todos,
                :member => {:toggle_check => :post},
                :collection => {:check_deferred => :post}
  map.with_options :controller => "todos" do |todos|
    todos.home '', :action => "index"
    todos.tickler 'tickler', :action => "list_deferred"
    todos.done 'done', :action => "completed"
    todos.done_archive 'done/archive', :action => "completed_archive"
    todos.tag '/todos/tag/:name', :action => "tag"
  end

  # Context Routes
  map.resources :contexts, :collection => {:order => :post} 
  map.connect 'context/:context/feed/:action/:login/:token', :controller => 'feed'
  map.connect 'contexts/feed/:feedtype/:login/:token', :controller => 'feed', :action => 'list_contexts_only'

  # Projects Routes
  map.resources :projects, :collection => {:order => :post} 
  map.connect 'project/:project/feed/:action/:login/:token', :controller => 'feed'
  map.connect 'projects/feed/:feedtype/:login/:token', :controller => 'feed', :action => 'list_projects_only'

  # Notes Routes
  map.resources :notes

  # Feed Routes
  map.connect 'feeds', :controller => 'feedlist', :action => 'index'
  map.connect 'feed/:action/:login/:token', :controller => 'feed'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
