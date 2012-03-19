$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'aruba'
require 'fileutils'

begin
  # rspec-2
  require 'rspec/expectations'
rescue LoadError
  # rspec-1
  require 'spec/expectations'
end

Before do
  FileUtils.rm(Dir['config/*.yml'])
end