class ProjectsScenario < Scenario::Base
  def load
    create_project :build_time_machine, 'Build a working time machine'
    create_project :make_more_money, 'Make more money than Billy Gates'
    create_project :evict_dinosaurs, 'Evict dinosaurs from the garden'
    create_project :attend_railsconf, 'Attend RailsConf'
  end

  def create_project(identifier, name)
    attributes = {
      :name       => name,
      :state      => 'active',
      :created_at => 4.day.ago,
      :updated_at => 1.minute.ago
    }
    create_model :project,
      identifier || attributes[:name].split.first.downcase.to_sym,
      attributes
  end
end
