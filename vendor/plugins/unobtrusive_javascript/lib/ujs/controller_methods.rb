module UJS::ControllerMethods
  def self.included(base)
    base.class_eval do
      before_filter :store_controller_for_helpers
      before_filter :initialise_js_behaviours 
      after_filter  :store_js_behaviours
    end
  end
  
  # Lets you register javascript behaviours from within
  # the controller. For a description of the different options
  # available, see UJS::Helpers#apply_behaviour (note: 
  # this function does not take a block like the view helper version)
  def apply_behaviour(selector, behaviour, opts={})
    opts.reverse_merge!(:prevent_default => false)
    @js_behaviours.add_rule(selector, behaviour, opts[:prevent_default])
  end
  
  def cache_behaviours
    @js_behaviours.enable_cache
  end
  
  def reapply_behaviours_after_ajax=(val)
    @js_behaviours.reapply_after_ajax = val
  end
  
  # Make American and English spellings both work for apply_behaviour
  alias_method :apply_behavior, :apply_behaviour

  protected
    # Initialises the javascript behaviours
    def initialise_js_behaviours
      @js_behaviours = UJS::BehaviourScript.new(@cache_behaviours)
    end
  
    # Clears the array of registered javascript behaviours
    def reset_js_behaviours
      session[:js_behaviours] = nil
    end
    
    # Returns a BehaviourScript from the behaviours serialized to the session
    def js_behaviours
      return nil if session[:js_behaviours].nil?
      UJS::BehaviourScriptConverter.convert_from_hash(session[:js_behaviours])
    end
    
    # Stores all registered javascript behaviours in the session as a hash
    def store_js_behaviours
      session[:js_behaviours] = @js_behaviours.to_hash
    end
    
    def store_controller_for_helpers
      ActionView::Helpers.current_controller = self
    end
end