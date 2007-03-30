require 'selenium_on_rails_config'
envs = SeleniumOnRailsConfig.get :environments

if envs.include? RAILS_ENV
  #initialize the plugin
  $LOAD_PATH << File.dirname(__FILE__) + "/lib/controllers"
  require 'selenium_controller'
  require File.dirname(__FILE__) + '/routes'

else
  #erase all traces
  $LOAD_PATH.delete lib_path
  
  #but help user figure out what to do
  unless RAILS_ENV == 'production' # don't pollute production
    require File.dirname(__FILE__) + '/switch_environment/init'
  end
end

