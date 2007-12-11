require 'simply_helpful'
ActionController::Base.send :include, SimplyHelpful::RecordIdentificationHelper
ActionController::Base.helper SimplyHelpful::RecordIdentificationHelper,
                              SimplyHelpful::RecordTagHelper
