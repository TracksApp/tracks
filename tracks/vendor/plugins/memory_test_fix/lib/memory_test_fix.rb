# MemoryTestFix
def in_memory_database?
  ENV["RAILS_ENV"] == "test" and 
  ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLiteAdapter and
  Rails::Configuration.new.database_configuration['test']['database'] == ':memory:'
end

if in_memory_database?
  puts "Creating sqlite in memory database"
  load "#{RAILS_ROOT}/db/schema.rb" # use db agnostic schema by default
#  ActiveRecord::Migrator.up('db/migrate') # use migrations
end
