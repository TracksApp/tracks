desc "Migrate the database according to the migrate scripts in db/migrate (only supported on PG/MySQL). A specific version can be targetted with VERSION=x"
task :migrate => :environment do
  ActiveRecord::Migrator.migrate(File.dirname(__FILE__) + '/db/migrate/', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end