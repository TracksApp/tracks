ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Index Route
  map.connect '', :controller => 'todo', :action => 'list'

  # Login Routes
  map.connect 'login', :controller => 'login', :action => 'login' 
  map.connect 'logout', :controller => 'login', :action => 'logout'
  map.connect 'signup', :controller => 'login', :action => 'signup'

  # ToDo Routes
  map.connect 'completed', :controller => 'todo', :action => 'completed'
  map.connect 'delete/todo/:id', :controller =>'todo', :action => 'destroy'

  # Context Routes
  map.connect 'contexts', :controller => 'context', :action => 'list'
  map.connect 'add/context', :controller => 'context', :action => 'new'
  map.connect 'context/:id', :controller=> 'context', :action => 'show'
  map.connect 'context/:name', :controller => 'context', :action => 'show'
  map.connect 'delete/context/:id', :controller => 'context', :action => 'destroy'

  # Projects Routes
  map.connect 'projects', :controller => 'project', :action => 'list'
  map.connect 'add/project', :controller => 'project', :action => 'new'
  map.connect 'project/:name', :controller => 'project', :action => 'show'
  map.connect 'project/:id', :controller => 'project', :action => 'show'
  map.connect 'delete/project/:id', :controller => 'project', :action => 'destroy'


  map.connect 'add_item', :controller => 'todo', :action => 'add_item'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
