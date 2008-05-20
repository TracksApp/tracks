require 'active_record'
require 'active_record/fixtures'

ActiveRecord::Base.logger = Logger.new(File.join(RAILS_ROOT, 'test.log'))

# Load the database.yml from #{plugin_path}/test/config if it exists
if file = PTK::Configuration.find_path(:database)

  config = YAML::load_file(file)
  ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

  # Load a schema if it exists
  if schema = PTK::Configuration.find_path(:schema)

    load(schema)

    # Setup fixtures if the directory exists
    if fixtures = PTK::Configuration.find_path(:fixtures)

      PTK::LoadPath.add fixtures

      Test::Unit::TestCase.fixture_path = fixtures
      Test::Unit::TestCase.use_instantiated_fixtures  = false

    end
  end
end