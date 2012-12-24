Tracksapp::Application.routes.draw do
  mount Tolk::Engine => '/tolk', :as => 'tolk' if Rails.env=='development'

  root :to => 'todos#index'
  
  match 'login' => 'login#login'
  match 'login/expire_session' => 'login#expire_session'
  match 'login/check_expiry' => 'login#check_expiry'
  match 'logout' => 'login#logout'
  
  match "tickler" => "todos#list_deferred"
  match 'review' => "projects#review"
  match 'calendar' => "todos#calendar"
  match 'done' => "stats#done", :as => 'done_overview'
  
  match 'search' => 'search#index'
  match 'search/results' => 'search#results', :via => 'post'

  match 'data' => "data#index"
  match 'data/csv_notes' => 'data#csv_notes'
  match 'data/yaml_export' => 'data#yaml_export'
  match 'data/xml_export' => 'data#xml_export'
  match 'data/csv_actions' => 'data#csv_actions'
  
  match 'integrations' => "integrations#index"
  match 'integrations/rest_api' => "integrations#rest_api", :as => 'rest_api_docs'
  match 'integrations/cloudmailin' => 'integrations#cloudmailin'
  match 'integrations/search_plugin' => "integrations#search_plugin", :as => 'search_plugin'
  match 'integrations/google_gadget.xml' => 'integrations#google_gadget', :as => 'google_gadget'
  match 'integrations/get_applescript1.js' => 'integrations#get_applescript1'
  match 'integrations/get_applescript2.js' => 'integrations#get_applescript2'
  match 'integrations/get_quicksilver_applescript.js' => 'integrations#get_quicksilver_applescript'
  
  match 'preferences' => "preferences#index"
  match 'preferences/render_date_format' => "preferences#render_date_format"
  
  match 'feeds' => "feedlist#index", :as => 'feeds'
  match 'feedlist/get_feeds_for_context' => 'feedlist#get_feeds_for_context'
  match 'feedlist/get_feeds_for_project' => 'feedlist#get_feeds_for_project'
  
  match 'stats' => 'stats#index'
  match 'stats/actions_done_last12months_data' => 'stats#actions_done_last12months_data'
  match 'stats/actions_done_last_years' => 'stats#actions_done_last_years'
  match 'stats/actions_done_lastyears_data' => 'stats#actions_done_lastyears_data'
  match 'stats/actions_done_last30days_data' => 'stats#actions_done_last30days_data'
  match 'stats/actions_completion_time_data' => 'stats#actions_completion_time_data'
  match 'stats/actions_running_time_data' => 'stats#actions_running_time_data'
  match 'stats/actions_visible_running_time_data' => 'stats#actions_visible_running_time_data'
  match 'stats/actions_open_per_week_data' => 'stats#actions_open_per_week_data'
  match 'stats/context_total_actions_data' => 'stats#context_total_actions_data'
  match 'stats/context_running_actions_data' => 'stats#context_running_actions_data'
  match 'stats/actions_day_of_week_all_data' => 'stats#actions_day_of_week_all_data'
  match 'stats/actions_day_of_week_30days_data' => 'stats#actions_day_of_week_30days_data'
  match 'stats/actions_time_of_day_all_data' => 'stats#actions_time_of_day_all_data'
  match 'stats/actions_time_of_day_30days_data' => 'stats#actions_time_of_day_30days_data'
  match 'stats/show_selected_actions_from_chart/:id' => 'stats#show_selected_actions_from_chart', :as => 'show_actions_from_chart'
  
  resources :contexts do
    member do
      get 'done_todos'
      get 'all_done_todos'
    end
    collection do
      post 'order'
      get 'done'
    end
    resources :todos
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
    resources :todos
  end
  
  resources :todos do
    member do
      put 'toggle_check'
      put 'toggle_star'
      put 'defer'
      get 'show_notes'
      get 'convert_to_project' # TODO: convert to PUT/POST
      delete 'remove_predecessor' # TODO: convert to PUT/POST
      post 'change_context'
    end
    collection do
      get 'done'
      get 'all_done'
      post 'check_deferred'
      post 'filter_to_context'
      post 'filter_to_project'
      post 'add_predecessor'
    end
  end
  match 'todos/tag/:name' => 'todos#tag', :as => :tag
  match 'tags.autocomplete' => "todos#tags", :format => 'autocomplete'

  match 'todos/done/tag/:name' => "todos#done_tag", :as => :done_tag
  match 'todos/all_done/tag/:name' => "todos#all_done_tag", :as => :all_done_tag
  match 'auto_complete_for_predecessor' => 'todos#auto_complete_for_predecessor'
  match 'mobile' => 'todos#index', :format => 'm'
  match 'm' => 'todos#index', :format => 'm'

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
  resources :preferences
      
end
