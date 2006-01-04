$:.unshift(File.dirname(__FILE__) + '/..lib')
$:.unshift(File.dirname(__FILE__) + '/fixtures/helpers')

rails_dir = File.dirname(__FILE__) + '/../../../rails'
if File.directory?(rails_dir)
  lib_dir = rails_dir + '/actionpack/lib'
  require lib_dir + '/action_controller'
  require lib_dir + '/action_controller/test_process'
else
  require 'rubygems'
  require 'action_controller'
  require 'action_controller/test_process'
end
require 'test/unit'
require 'init'

ActionController::Base.logger = nil
ActionController::Base.ignore_missing_templates = false
ActionController::Routing::Routes.reload rescue nil

