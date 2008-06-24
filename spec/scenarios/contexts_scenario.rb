class ContextsScenario < Scenario::Base
  uses :users

  def load
    %w(Call Email Errand Someday).each_with_index do |context, index|
      create_context context, index+1
    end
  end

  def create_context(name, position)
    create_model :context, name.downcase.to_sym,
      :name     => name,
      :position => position,
      :hide     => name == 'Someday' ? true : false,
      :created_at => Time.now,
      :updated_at => Time.now,
      :user_id    => user_id(:sean)
  end
end
