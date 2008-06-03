desc "Load exported fixtures (in db/exported_fixtures) into the current environment's database"
task :load_exported_fixtures => :environment do
  require 'active_record/fixtures'
  ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
  Dir.glob(File.join(RAILS_ROOT, 'db', 'exported_fixtures', '*.{yml,csv}')).each do |fixture_file|
    Fixtures.create_fixtures('db/exported_fixtures', File.basename(fixture_file, '.*'))
  end
end