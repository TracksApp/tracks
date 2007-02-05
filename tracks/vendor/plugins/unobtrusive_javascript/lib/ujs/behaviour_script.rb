class UJS::BehaviourScript
  attr_reader :rules
  attr_writer :reapply_after_ajax
  
  def initialize(cache=false, reapply_after_ajax=true)
    @rules, @cache, @reapply_after_ajax = [], cache, reapply_after_ajax
  end
  
  def add_rule(selector, javascript, cancel_default=false)
    javascript = javascript << cancel_default_js if cancel_default
    @rules << [selector, javascript]
  end
  
  def cache?
    @cache
  end
  
  def enable_cache
    @cache = true
  end
  
  def reapply_after_ajax?
    @reapply_after_ajax
  end
  
  # Renders behaviour block and option JavaScript.
  def to_s
    (@rules && !@rules.empty?) ? "Event.addBehavior({\n#{rule_js}\n});" + option_js : ''
  end
  
  # Uses behaviour script converter to conver to a hash for session storage
  def to_hash
    UJS::BehaviourScriptConverter.convert_to_hash(self)
  end
  
  protected  
    # Renders a collection of behaviour rules in javascript format
    def rule_js
      @rules.uniq.collect { |sel, js| behaviour_rule(sel, js) }.join(",\n")
    end
  
    # Renders behaviour rule javascript for the behaviours file
    def behaviour_rule(selector, behaviour)
      "\"#{selector}\": function(event) {\n#{behaviour}\n}"
    end
  
    def option_js
      reapply_after_ajax? ? '' : "\nEvent.addBehavior.reapplyAfterAjax = false;"
    end
    
    def cancel_default_js
      " return false;"
    end
end