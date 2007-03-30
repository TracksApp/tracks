ENV["RAILS_ENV"] = "test"

# load plugin test kit
require File.join(File.dirname(__FILE__), 'ptk_helper')

# load stubba and other stubs
require 'stubba'
require 'stubs/controller_stub'

# load plugin files
require 'actionview_helpers_patches'
require 'prototype_helper_patches'
require 'scriptaculous_helper_patches'
require 'asset_tag_helper_patches'
require 'tag_helper_patches'
require 'behaviour_caching'

$:.unshift(File.join(File.dirname(__FILE__), '../lib/'))

def initialize_test_request
  @controller = ControllerStub.new
  @request = ActionController::TestRequest.new
  @response = ActionController::TestResponse.new
  get :index
end