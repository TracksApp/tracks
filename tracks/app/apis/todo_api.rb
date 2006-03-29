class TodoApi < ActionWebService::API::Base
  api_method :new_todo,
             :expects => [{:username => :string}, {:token => :string}, {:context_id => :int}, {:description => :string}],
             :returns => [:int]
end
