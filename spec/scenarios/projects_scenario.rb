class ProjectsScenario < Scenario::Base
  def load
    ['Build a working time machin',
     'Make more money than Billy Gates',
     'Evict dinosaurs from the garden',
     'Attend RailsConf'].each_with_index do |project, index|
      create_record :project, project.split.first.downcase.to_sym,
        :name         => project,
        :description  => '',
        :position => index + 1,
        :state    => 'active',
        :created_at => Time.now,
        :updated_at => Time.now
    end
  end
end
