class TodosScenario < Scenario::Base
  uses :contexts, :projects, :users

  def load
    create_todo :bill,
      :description => 'Call Bill Gates to find out how much he makes per day',
      :user        => :sean,
      :context     => :call,
      :project     => :make_more_money
    create_todo :bank,
      :description => 'Call my bank',
      :user        => :sean,
      :context     => :call,
      :project     => :make_more_money
  end

  def create_todo(identifier, options={})
    context = options.delete(:context)
    project = options.delete(:project)
    user    = options.delete(:user)
    attributes = {
      :state  => 'active',
      :created_at => 1.week.ago,
      :context_id  => context_id(context),
      :project_id  => project_id(project),
      :user_id     => user_id(user)    
    }.merge(options)
    create_model :todo, identifier, attributes
  end
end
