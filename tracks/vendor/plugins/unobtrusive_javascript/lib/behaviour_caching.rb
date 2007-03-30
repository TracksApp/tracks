module UJS
  module BehaviourCaching
    
    def self.included(base)
      base.extend ControllerClassMethods
    end
    
    attr_accessor :cache_behaviours

    module ControllerClassMethods
      
      # Also file caching of the behaviour for hidden actions.  This actually
      # write the javascript file into the public directory (or given cache dir)
      # in the same style as page caching.  Which means requests for the behaviour
      # will not hit the application at all.  Use this for reasonably static behaviours.
      #
      # NB. If you use caches_page or caches_action your behaviours will automatically ne
      # cached in this way.  expire_page and expire_action also automatically expire the 
      # cached behaviour.
      #
      #   caches_behaviour :index, :register
      #
      # See expire_behaviour to expire cached behaviours.
      def caches_behaviour(*actions)
        actions.each do |action|
          class_eval "prepend_before_filter { |c| c.cache_behaviours = (c.action_name == '#{action}') }"
        end
      end
      
      alias_method :caches_behavior, :caches_behaviour
      
      def caches_page(*actions)
        caches_behaviour(*actions)
        super
      end
      
      def caches_action(*actions)
        caches_behaviour(*actions)
        super
      end
      
    end
    
    # Expires the behaviours for the given url options.
    #
    #     expire_behaviour :action => 'index'
    def expire_behaviour(options={})
      self.class.expire_page "/behaviour#{url_for(options)}.js"
    end
    
    alias_method :expire_behavior, :expire_behaviour
    
    def expire_page(options={})
      expire_behaviour(options)
      super
    end
    
    def expire_action(options={})
      if options[:action].is_a?(Array)
        options[:action].dup.each do |action|
          expire_behaviour(options.merge({ :action => action }))
        end
      else
        expire_behaviour(options)
      end
      super
    end
    
  end
end