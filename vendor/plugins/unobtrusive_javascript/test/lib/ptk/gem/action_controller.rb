require 'action_pack'
require 'action_controller'
require 'action_controller/test_process'

ActionController::Base.ignore_missing_templates = true

if PTK::Configuration.load :routes
  ActionController::Routing::Routes.reload rescue nil
end

class ActionController::Base; def rescue_action(e) raise e end; end
