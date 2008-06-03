ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  UJS::routes
end