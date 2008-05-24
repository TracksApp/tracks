require 'action_mailer'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
