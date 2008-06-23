namespace :db do
  namespace :scenario do
    desc "Load a scenario into the current environment's database using SCENARIO=scenario_name"
    task :load => 'db:reset' do
      scenario_name = ENV['SCENARIO'] || 'default'
      begin
        klass = Scenarios.load(scenario_name)
        puts "Loaded #{klass.name.underscore.gsub('_', ' ')}."
      rescue Scenarios::NameError => e
        if scenario_name == 'default'
          puts "Error! Set the SCENARIO environment variable or define a DefaultScenario class."
        else
          puts "Error! Invalid scenario name [#{scenario_name}]."
        end
        exit(1)
      end
    end
  end
end