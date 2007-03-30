require 'actionview_helpers_patches'
require 'prototype_helper_patches'
require 'scriptaculous_helper_patches'
require 'asset_tag_helper_patches'
require 'tag_helper_patches'
require 'behaviour_caching'
require 'ujs'

# make plugin controllers and views available to app
config.load_paths += %W(#{UJS::PLUGIN_CONTROLLER_PATH})
Rails::Initializer.run(:set_load_path, config)

# add methods to action controller base
ActionController::Base.send(:include, UJS::ControllerMethods)

# load in the helpers and caching code
ActionController::Base.send(:helper, UJS::Helpers)
ActionController::Base.send(:include, UJS::BehaviourCaching)

# require the controller
require 'unobtrusive_javascript_controller'