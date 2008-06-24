require File.expand_path(File.dirname(__FILE__) + '/../testing/plugit_descriptor')

TESTING_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../testing")
TESTING_TMP = "#{TESTING_ROOT}/tmp"

require 'fileutils'
FileUtils.mkdir_p(TESTING_TMP)
FileUtils.touch("#{TESTING_TMP}/test.log")

require 'logger'
RAILS_DEFAULT_LOGGER = Logger.new("#{TESTING_TMP}/test.log")
RAILS_DEFAULT_LOGGER.level = Logger::DEBUG

ActiveRecord::Base.silence do
  ActiveRecord::Base.configurations = {'sqlite3' => {
    'adapter' => 'sqlite3',
    'database' => "#{TESTING_TMP}/sqlite3.db"
  }}
  ActiveRecord::Base.establish_connection 'sqlite3'
  load "#{TESTING_ROOT}/schema.rb"
end

require "models"
require "scenarios"