Tracksapp::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"
  
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  root :to => 'todos#index'
  
  match "tickler" => "todos#list_deferred"
  match 'review' => "projects#review"
  match 'login' => 'users#login'
  match 'login_cas' => 'users#login_cas'
  match 'logout' => 'users#logout'
  match 'calendar' => "todos#calendar"
  match 'stats' => 'stats#index'
  match 'done' => "stats#done", :as => 'done_overview'
  match 'integrations' => "integrations#index"
  match 'integrations/rest_api' => "integrations#rest_api", :as => 'rest_api_docs'
  match 'integrations/cloudmailin' => 'integrations#cloudmailin'
  match 'integrations/search_plugin.xml' => "integrations#search_plugin", :as => 'search_plugin'
  match 'integrations/google_gadget.xml' => 'integrations#google_gadget', :as => 'google_gadget'
  match 'preferences' => "preferences#index"
  match 'preferences/render_date_format' => "preferences#render_date_format"
  
  resources :contexts do
    collection do
      post 'order'
      get 'done'
    end
    member do
      get 'done_todos'
      get 'all_done_todos'
    end
  end
  
  resources :projects do
    member do
      get 'done_todos'
      get 'all_done_todos'
      get 'set_reviewed'  # TODO: convert to PUT/POST
    end
    collection do
      get 'done'
      post 'order'
      post 'alphabetize'
      post 'actionize'
    end
  end
  
  resources :todos do
    member do
      put 'toggle_check'
      put 'toggle_star'
      put 'defer'
    end
    collection do
      get 'done'
      get 'all_done'
      post 'check_deferred'
      post 'filter_to_context'
      post 'filter_to_project'
    end
  end
  match 'todos/tag/:name' => 'todos#tag', :as => :tag

  resources :recurring_todos do
    member do
      put 'toggle_check'
      put 'toggle_star'
    end
    collection do
      get 'done'
    end
  end
  
  resources :users do
    member do
      get 'change_password'
      get 'change_auth_type'
      get 'complete'
      post 'update_password'
      post 'update_auth_type'
      post 'refresh_token'
    end
  end
  match 'signup' => "users#new"
  
  resources :notes
  
  # map.resources :users,
  #   :member => {:change_password => :get, :update_password => :post,
  #   :change_auth_type => :get, :update_auth_type => :post, :complete => :get,
  #   :refresh_token => :post }
  #
  # map.with_options :controller => :users do |users|
  #   users.signup 'signup', :action => "new"
  # end
  #
  # map.resources :contexts, :collection => {:order => :post, :done => :get}, :member => {:done_todos => :get, :all_done_todos => :get} do |contexts|
  #   contexts.resources :todos, :name_prefix => "context_"
  # end
  #
  # map.resources :projects,
  #   :collection => {:order => :post, :alphabetize => :post, :actionize => :post, :done => :get},
  #   :member => {:done_todos => :get, :all_done_todos => :get, :set_reviewed => :get} do |projects|
  #     projects.resources :todos, :name_prefix => "project_"
  # end
  #
  # map.with_options :controller => :projects do |projects|
  #   projects.review 'review', :action => :review
  # end
  #
  # map.resources :notes
  #
  # map.resources :todos,
  #   :member => {:toggle_check => :put, :toggle_star => :put, :defer => :put},
  #   :collection => {:check_deferred => :post, :filter_to_context => :post, :filter_to_project => :post, :done => :get, :all_done => :get
  # }
  #
  # map.with_options :controller => :todos do |todos|
  #   todos.home '', :action => "index"
  #   todos.tickler 'tickler.:format', :action => "list_deferred"
  #   todos.mobile_tickler 'tickler.m', :action => "list_deferred", :format => 'm'
  #
  #   # This route works for tags with dots like /todos/tag/version1.5
  #   # please note that this pattern consumes everything after /todos/tag
  #   # so /todos/tag/version1.5.xml will result in :name => 'version1.5.xml'
  #   # UPDATE: added support for mobile view. All tags ending on .m will be
  #   # routed to mobile view of tags.
  #   todos.mobile_tag 'todos/tag/:name.m', :action => "tag", :format => 'm'
  #   todos.text_tag 'todos/tag/:name.txt', :action => "tag", :format => 'txt'
  #   todos.tag 'todos/tag/:name', :action => "tag", :name => /.*/
  #   todos.done_tag 'todos/done/tag/:name', :action => "done_tag"
  #   todos.all_done_tag 'todos/all_done/tag/:name', :action => "all_done_tag"
  #
  #   todos.tags 'tags.autocomplete', :action => "tags", :format => 'autocomplete'
  #   todos.auto_complete_for_predecessor 'auto_complete_for_predecessor', :action => 'auto_complete_for_predecessor'
  #
  #   todos.calendar 'calendar.ics', :action => "calendar", :format => 'ics'
  #   todos.calendar 'calendar.xml', :action => "calendar", :format => 'xml'
  #   todos.calendar 'calendar', :action => "calendar"
  #
  #   todos.hidden 'hidden.xml', :action => "list_hidden", :format => 'xml'
  #
  #   todos.mobile 'mobile', :action => "index", :format => 'm'
  #   todos.mobile_abbrev 'm', :action => "index", :format => 'm'
  #   todos.mobile_abbrev_new 'm/new', :action => "new", :format => 'm'
  #
  #   todos.mobile_todo_show_notes 'todos/notes/:id.m', :action => "show_notes", :format => 'm'
  #   todos.todo_show_notes 'todos/notes/:id', :action => "show_notes"
  #   todos.done_todos 'todos/done', :action => :done
  #   todos.all_done_todos 'todos/all_done', :action => :all_done
  # end
  # map.root :controller => 'todos' # Make OpenID happy because it needs #root_url defined
  #
  # map.resources :recurring_todos, :collection => {:done => :get},
  #   :member => {:toggle_check => :put, :toggle_star => :put}
  # map.with_options :controller => :recurring_todos do |rt|
  #   rt.recurring_todos 'recurring_todos', :action => 'index'
  # end
  #
  # map.with_options :controller => :login do |login|
  #   login.login 'login', :action => 'login'
  #   login.login_cas 'login_cas', :action => 'login_cas'
  #   login.formatted_login 'login.:format', :action => 'login'
  #   login.logout 'logout', :action => 'logout'
  #   login.formatted_logout 'logout.:format', :action => 'logout'
  # end
  #
  # map.with_options :controller => :feedlist do |fl|
  #   fl.mobile_feeds 'feeds.m', :action => 'index', :format => 'm'
  #   fl.feeds        'feeds',   :action => 'index'
  # end
  #
  # map.with_options :controller => :integrations do |i|
  #   i.integrations  'integrations', :action => 'index'
  #   i.rest_api_docs 'integrations/rest_api', :action => "rest_api"
  #   i.search_plugin 'integrations/search_plugin.xml', :action => 'search_plugin', :format => 'xml'
  #   i.google_gadget 'integrations/google_gadget.xml', :action => 'google_gadget', :format => 'xml'
  #   i.cloudmailin   'integrations/cloudmailin', :action => 'cloudmailin'
  # end
  #
  # map.with_options :controller => :preferences do |p|
  #   p.preferences 'preferences', :action => 'index'
  #   p.preferences_date_format 'preferences/render_date_format', :action => 'render_date_format'
  # end
  #
  # map.with_options :controller => :stats do |stats|
  #   stats.stats 'stats',  :action => 'index'
  #   stats.done_overview 'done', :action => 'done'
  # end
  #
  # map.search 'search', :controller => 'search', :action => 'index'
  # map.data 'data', :controller => 'data', :action => 'index'
  #
  # Translate::Routes.translation_ui(map) if Rails.env != "production"
  #
  # # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id'
  #
  
end
