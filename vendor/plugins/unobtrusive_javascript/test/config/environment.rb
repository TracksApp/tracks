Rails::Initializer.run do |config|
  config.cache_classes = true
  config.whiny_nils = true
  config.action_controller.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = true
end