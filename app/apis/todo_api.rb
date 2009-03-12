class TodoApi < ActionWebService::API::Base
  api_method :new_todo,
             :expects => [{:username => :string}, {:token => :string}, {:context_id => :int}, {:description => :string}, {:notes => :string}],
             :returns => [:int]

  api_method :new_todo_for_project,
             :expects => [{:username => :string}, {:token => :string}, {:context_id => :int}, {:project_id => :int}, {:description => :string}, {:notes => :string}],
             :returns => [:int]
  
  api_method :new_rich_todo,
             :expects => [{:username => :string}, {:token => :string}, {:default_context_id => :int}, {:description => :string}, {:notes => :string}],
             :returns => [:int]
             
  api_method :list_contexts,
             :expects => [{:username => :string}, {:token => :string}],
             :returns => [[Context]]

 api_method :list_projects,
            :expects => [{:username => :string}, {:token => :string}],
            :returns => [[Project]]

end
