module ActionView::Helpers
  def self.current_controller=(controller)
    @@current_controller = controller
  end
  
  def self.current_controller
    @@current_controller
  end
end

class ActionView::Helpers::InstanceTag
  include UJS::Helpers
  
  def current_controller
    ActionView::Helpers.current_controller
  end
end