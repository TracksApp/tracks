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
  
  # Index Route
  map.connect '', :controller => 'todo', :action => 'list'

  # Login Routes
  map.connect 'login', :controller => 'login', :action => 'login' 
  map.connect 'logout', :controller => 'login', :action => 'logout'
  map.connect 'signup', :controller => 'login', :action => 'signup'

  # ToDo Routes
  map.connect 'done', :controller => 'todo', :action => 'completed'
  map.connect 'delete/todo/:id', :controller =>'todo', :action => 'destroy'

  # Context Routes
  map.connect 'context/new_context', :controller => 'context', :action => 'new_context'
  map.connect 'context/add_item', :controller => 'context', :action => 'add_item'
  map.connect 'context/order', :controller => 'context', :action => 'order'
  map.connect 'context/:id', :controller=> 'context', :action => 'show', :requirements => {:id => /\d+/}
  map.connect 'context/:name', :controller => 'context', :action => 'show'
  map.connect 'contexts', :controller => 'context', :action => 'list'

  # Projects Routes
  map.connect 'project/new_project', :controller => 'project', :action => 'new_project'
  map.connect 'project/add_item/:id', :controller => 'project', :action => 'add_item'
  map.connect 'project/toggle_check/:id', :controller => 'project', :action => 'toggle_check'
  map.connect 'project/order', :controller => 'project', :action => 'order'
  map.connect 'project/:id', :controller => 'project', :action => 'show', :requirements => {:id => /\d+/}
  map.connect 'project/:name', :controller => 'project', :action => 'show'
  map.connect 'projects', :controller => 'project', :action => 'list'

  # Notes Routes
  map.connect 'note/add', :controller => 'note', :action => 'add'
  map.connect 'note/update/:id', :controller => 'note', :action => 'update', :id => 'id'
  map.connect 'note/:id', :controller => 'note', :action => 'show', :id => 'id'
  map.connect 'notes', :controller => 'note', :action => 'index'

  # Feed Routes
  map.connect 'feeds', :controller => 'todo', :action => 'feeds'
  map.connect 'feed/:action/:name/:token', :controller => 'feed'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
