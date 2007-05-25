
begin
  require 'rubygems'
  require 'ruby-debug' 
  Debugger.start
rescue Object
end

# load the applicaiton's test helper
begin
  require File.dirname(__FILE__) + '/../../../../test/test_helper' 
rescue LoadError
  require '~/projects/miscellaneous/cookbook/test/test_helper'
end

WORKING_DIR = File.dirname(__FILE__)

Inflector.inflections {|i| i.irregular 'fish', 'fish' }

# fixtures
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path = WORKING_DIR + "/fixtures")
# models
$LOAD_PATH.unshift(WORKING_DIR + "/models")
# extension modules
$LOAD_PATH.unshift(WORKING_DIR + "/modules")

class Test::Unit::TestCase
  self.use_transactional_fixtures = (not ActiveRecord::Base.connection.is_a? ActiveRecord::ConnectionAdapters::MysqlAdapter)
  self.use_instantiated_fixtures  = false
end

# test schema
load(File.dirname(__FILE__) + "/schema.rb")

