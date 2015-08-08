Rails.application.routes.draw do
  mount Tolk::Engine => '/tolk', :as => 'tolk' if Rails.env=='development'

  root :to => 'todos#index'

  post 'mailgun/mime' => 'mailgun#mailgun'

  post 'login' => 'login#login'
  get 'login' => 'login#login'
  get 'login/check_expiry' => 'login#check_expiry'
  get 'logout' => 'login#logout'

  get "tickler" => "todos#list_deferred"
  get 'review' => "projects#review"
  get 'calendar' => "calendar#show"
  get 'done' => "stats#done", :as => 'done_overview'

  get 'search' => 'search#index'
  post 'search/results' => 'search#results', :via => 'post'

  get 'data' => "data#index"
  get 'data/csv_notes' => 'data#csv_notes'
  get 'data/yaml_export' => 'data#yaml_export'
  get 'data/xml_export' => 'data#xml_export'
  get 'data/csv_actions' => 'data#csv_actions'

  get 'integrations' => "integrations#index"
  get 'integrations/rest_api' => "integrations#rest_api", :as => 'rest_api_docs'
  post 'integrations/cloudmailin' => 'integrations#cloudmailin'
  get 'integrations/search_plugin' => "integrations#search_plugin", :as => 'search_plugin'

  get 'preferences' => "preferences#index"
  get 'preferences/render_date_format' => "preferences#render_date_format"

  get 'feeds' => "feedlist#index", :as => 'feeds'
  get 'feedlist/get_feeds_for_context' => 'feedlist#get_feeds_for_context'
  get 'feedlist/get_feeds_for_project' => 'feedlist#get_feeds_for_project'

  get 'stats' => 'stats#index'
  get 'stats/actions_done_last12months_data' => 'stats#actions_done_last12months_data'
  get 'stats/actions_done_last_years' => 'stats#actions_done_last_years'
  get 'stats/actions_done_lastyears_data' => 'stats#actions_done_lastyears_data'
  get 'stats/actions_done_last30days_data' => 'stats#actions_done_last30days_data'
  get 'stats/actions_completion_time_data' => 'stats#actions_completion_time_data'
  get 'stats/actions_running_time_data' => 'stats#actions_running_time_data'
  get 'stats/actions_visible_running_time_data' => 'stats#actions_visible_running_time_data'
  get 'stats/actions_open_per_week_data' => 'stats#actions_open_per_week_data'
  get 'stats/context_total_actions_data' => 'stats#context_total_actions_data'
  get 'stats/context_running_actions_data' => 'stats#context_running_actions_data'
  get 'stats/actions_day_of_week_all_data' => 'stats#actions_day_of_week_all_data'
  get 'stats/actions_day_of_week_30days_data' => 'stats#actions_day_of_week_30days_data'
  get 'stats/actions_time_of_day_all_data' => 'stats#actions_time_of_day_all_data'
  get 'stats/actions_time_of_day_30days_data' => 'stats#actions_time_of_day_30days_data'
  get 'stats/show_selected_actions_from_chart/:id' => 'stats#show_selected_actions_from_chart', :as => 'show_actions_from_chart'

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

  # match /todos/tag and put everything in :name, including extensions like .m and .txt.
  # This means the controller action needs to parse the extension and set format/content type
  # Needed for /todos/tag/first.last.m to work
  get 'todos/tag/:name' => 'todos#tag', :as => :tag, :format => false, :name => /.*/
  
  get 'attachments/:id/:filename' => "todos#attachment"
  get 'tags.autocomplete' => "todos#tags", :format => 'autocomplete'
  get 'todos/done/tag/:name' => "todos#done_tag", :as => :done_tag
  get 'todos/all_done/tag/:name' => "todos#all_done_tag", :as => :all_done_tag
  get 'auto_complete_for_predecessor' => 'todos#auto_complete_for_predecessor'
  get 'mobile' => 'todos#index', :format => 'm'
  get 'm' => 'todos#index', :format => 'm'

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
  get 'signup' => "users#new"

  resources :notes
  resources :preferences

  resources :data do
    collection do
      get :import
      post :csv_map
      post :csv_import
    end
  end

end
