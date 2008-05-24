module UJS
  # The helper methods in this module can all be passed as arguments to apply_behaviour and allow
  # you to reproduce common functionailty such as drag and drop and sorting in a simple way.  Think
  # of them as the apply_javascript equivilent to the Scriptaculous helpers.
  #
  # Usage:
  #
  #    apply_behaviour '.products', make_draggable
  #    apply_behaviour '.help', make_remote_link( :action => 'showhelp' )
  #    apply_behaviour '.todolist', make_sortable
  #
  module BehaviourHelper    
    
    # Make a link send an Ajax request.  options identical to linkt_to_remote except that
    # :url defaults to the href attribute of the link.
    def make_remote_link(options={})
      options[:url] ||= javascript_variable('this.href');
      "this.observe('click', function(event) {\n#{remote_function(options)};\nreturn false;\n});"
    end
    
    # Make a form submit via an Ajax request.  options identical remote_form except that
    # :url defaults to the action attribute of the form.
    def make_remote_form(options={})
      options[:url] ||= javascript_variable('this.action');
      options[:with] ||= 'Form.serialize(this)'
      "this.observe('submit', function(event) {\n#{remote_function(options)};\nreturn false;\n});"
    end
    
    # Observe a form or form field (specified with the type argument) using the given options
    # which are the same as observe_form and observe_field.
    def make_observed(type, options={})
      obs = (type.to_s == 'form') ? 'Form' : 'Form.Element'
      if options[:frequency] && options[:frequency] > 0
        build_observer_js("#{obs}.Observer", javascript_variable('this'), options)
      else
        build_observer_js("#{obs}.EventObserver", javascript_variable('this'), options)
      end
    end
  
    # Makes the children of the element sortable.
    def make_sortable(options={})
      sortable_element_js(javascript_variable('this'), options)
    end
    
    # Makes the element draggable.
    def make_draggable(options={})
      draggable_element_js(javascript_variable('this'), options)
    end
    
    # Makes the element a drop target.
    def make_drop_receiving(options={})
      drop_receiving_element_js(javascript_variable('this'), options)
    end
    
    def make_autocomplete # :nodoc:
    end
    
    def make_in_place_editor # :nodoc:
    end
    
  end
end