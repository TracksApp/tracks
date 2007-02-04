require 'pathname'
# default test helper
begin
  require File.dirname(__FILE__) + '/../../../../test/test_helper' 
rescue LoadError
  require '~/projects/miscellaneous/cookbook/test/test_helper'
end

Inflector.inflections {|i| i.irregular 'fish', 'fish' }

# fixtures
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path = File.dirname(__FILE__)  + "/fixtures/")
# models
$LOAD_PATH.unshift("#{Pathname.new(__FILE__).dirname.to_s}/models")

class Test::Unit::TestCase
  self.use_transactional_fixtures = true  # must stay true for tests to run on postgres or sqlite3
  self.use_instantiated_fixtures  = false
end

# test schema
load(File.dirname(__FILE__) + "/schema.rb")

