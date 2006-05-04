class TodoApi < ActionWebService::API::Base
  api_method :new_todo,
             :expects => [{:username => :string}, {:token => :string}, {:context_id => :int}, {:description => :string}],
             :returns => [:int]
             
  api_method :list_contexts,
             :expects => [{:username => :string}, {:token => :string}],
             :returns => [[Context]]

 api_method :list_projects,
            :expects => [{:username => :string}, {:token => :string}],
            :returns => [[Project]]

end
