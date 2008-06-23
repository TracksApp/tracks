class TodosScenario < Scenario::Base
  uses :contexts, :projects, :users

  def load
    create_record :todo, :billy,
      :description => "Call Bill Gates to find out how much he makes per day",
      :notes       => "~",
      :state       => 'active',
      :created_at  => 1.week.ago,
      :due         => 2.weeks.from_now,
      :completed_at => nil,
      :context      => context(:call),
      :project_id   => project_id(:make),
      :user_id      => user_id(:sean)
  end
end
