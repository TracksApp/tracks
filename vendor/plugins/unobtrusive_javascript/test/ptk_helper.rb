# Do not comment out this line; it sets the RAILS_ROOT constant and load paths, not Rails itself
require File.join(File.dirname(__FILE__), 'lib', 'ptk', 'boot')

PTK::Initializer.run do |setup|
  # You can also redefine the paths of certain directories and files, namely:
  #setup.paths.config       = File.join(RAILS_ROOT, 'config')
  #setup.paths.fixtures     = File.join(RAILS_ROOT, 'fixtures')

  #setup.paths.database     = File.join(setup.paths.config, 'database.yml')
  #setup.paths.schema       = File.join(setup.paths.config, 'schema.rb')
  #setup.paths.routes       = File.join(setup.paths.config, 'routes.rb')
  #setup.paths.environment  = File.join(setup.paths.config, 'environment.rb')
  
  # If any of these paths are set to ':ignore', no warnings will appear if they are missing.

  # Frameworks are the gems from Rails which you need PTK to load for your plugin.
  # The special :rails framework creates a fully-fledged Rails environment and requires
  # the environment.rb file.
  # Valid options are: :action_controller, :action_mailer, :active_record, :rails
  setup.frameworks = :action_controller # :active_record, :action_controller

  # Extra libraries of assertions and other common methods that provide more testing
  # utilities. To hand-pick which suites you want, uncomment the below 
  #setup.suites = :difference
  
  # If for some particular reason you do not want your plugin's init to be called
  # at the end of this block, uncomment the below:
  setup.init = false
end
