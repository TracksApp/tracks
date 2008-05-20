
begin
  require 'rubygems'
  require 'ruby-debug' 
  Debugger.start
rescue Object
end

HERE = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << HERE

# require 'integration/app/config/environment'
require 'integration/app/test/test_helper'

def silently
  stderr, $stderr = $stderr, StringIO.new
  yield
  $stderr = stderr
end

Inflector.inflections {|i| i.irregular 'fish', 'fish' }

$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path = HERE + "/fixtures")
$LOAD_PATH.unshift(HERE + "/models")
$LOAD_PATH.unshift(HERE + "/modules")

class Test::Unit::TestCase
  self.use_transactional_fixtures = !(ActiveRecord::Base.connection.is_a? ActiveRecord::ConnectionAdapters::MysqlAdapter rescue false)
  self.use_instantiated_fixtures  = false
end

# test schema
silently do
  load(HERE + "/schema.rb")
end
