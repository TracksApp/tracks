require File.dirname(__FILE__) + '/behaviour_helper'
require File.dirname(__FILE__) + '/javascript_proxies'

module UJS::Helpers
  include UJS::BehaviourHelper
  include UJS::JavascriptProxies
  
  # This is the core functionality of the plugin;
  # it allows you to attach javascript behaviour to your page
  # elements in an unobtrusive fashion. It takes three options:
  # * +selector+ - CSS selector and event. For a full overview of
  #   the selector syntax, see the event:Selectors website.
  #   http://encytemedia.com/event-selectors
  # * +behaviour+ - The javascript that you want to attach to the element
  #   and event specified by +selector+ as a string of javascript.
  # * +opts+ - A hash of additional options.
  #
  # Attaching a behaviour to an element on your page is as simple as
  # specifying the element and the event you want the behaviour attached
  # to, using the CSS selector format, and passing in a string of javascript:
  #
  #  <% apply_behaviour "#coollink:click", "alert('Hello World')" %>
  #
  # You can also make use of any of the built-in Rails helpers that
  # generate Javascript:
  #
  #  <% apply_behaviour "#coolink:click", visual_effect(:highlight, "coollink") %>
  #
  # You will have access to two javascript variables inside your javascript string:
  # * +this+: returns a reference to the HTML element that the behaviour was attached to
  # * +event+: the event the behaviour was attached to:
  #
  #  <% apply_behaviour "#coollink:click", "alert('You clicked '  this.id); Event.stop(event)" %>
  #
  # The following options can be set using the opts hash:
  #
  # * <tt>:external</tt> - If true, the behaviour will be attached to the external behaviour file.
  #   If false, it will be rendered directly in the page inside +script+ tags. Defaults to true.
  #
  # When setting <tt>:external</tt> to false, you <em>must</em> call the register_js_behaviour from
  # within ERb <em>output</em> blocks. If <tt>:external</tt> is true, you can use either output or non-output blocks.
  #
  # If you set :prevent_default to true the default action of the event is stopped (similar to calling event.stop).
  # This is very useful for hijacking links in order to provide some other behaviour.
  #
  # You can also pass a block to the function instead of a string of javascript - 
  # the block will be passed in a JavascriptGenerator object (+page+), the element (optional) 
  # and the event (optional). You can use the Javascript generator
  # to write your attached behaviour using Ruby:
  #
  #  <% apply_behaviour "#coollink:click" do |page, element, event|
  #       page.alert("Hi there, I'm going to fade away...")
  #       page.visual_effect :fade, element
  #     end %>
  def apply_behaviour(selector, *args, &block) #:yields: page, element, event
    opts = args.last.is_a?(Hash) ? args.pop : {}
    set_default_external!(opts)
    behaviour = normalise_behaviour_string(args.first || '')
        
    if block_given?
      generator = new_javascript_generator
      args = [generator, element_proxy(generator), event_proxy(generator)][0..block.arity-1]
      @template.instance_exec(*args, &block)
      behaviour = generator.to_s
    end
    
    if !opts[:external]
      render_inline_behaviour_block(selector, behaviour, opts)
    else
      @controller.apply_behaviour(selector, behaviour, opts) and return ''
    end
  end
  
  # Allow you to apply multiple behaviours with block syntax.
  #
  #   apply_behaviours do 
  #     on 'a:click', 'alert("boo")'
  #     on 'abbr:mouseover', 'showAbbr(this)'
  #   end
  def apply_behaviours(&block)
    mapper = BehaviourMapper.new(self).instance_eval &block
    mapper.to_s
  end
    
  # Make sure American and English spellings both work
  alias_method :apply_behavior, :apply_behaviour
  alias_method :apply_behaviors, :apply_behaviours
  
  protected
    # A convenient mapper class for applying
    # multiple behaviours at once.
    class BehaviourMapper
      def initialize(base)
        @base = base
        @output = ''
      end
      
      def on(*args, &block)
        @output << @base.apply_behaviour(*args, &block)
      end
      
      # delegate all other method calls to the view
      def method_missing(meth, *args)
        @base.send meth, *args
      end
      
      def to_s
        @output
      end
      
    end
  
    # Renders a block of javascript behaviours inside +script+ tags 
    # directly within the page 
    def render_inline_behaviour_block(selector, behaviour, opts)
      script = UJS::BehaviourScript.new
      script.add_rule(selector, behaviour)
      javascript_tag(script.to_s)
    end
  
    # Use this to set the default :external option for helper calls.
    # it set external to false if its an xhr request or false if it's a normal request.
    def set_default_external!(options)
      options.reverse_merge!(:external => !current_controller.request.xhr?)
    end
    
    # Returns a new JavascriptArgumentProxy for the element the behaviour
    # has been applied to.
    def element_proxy(generator)
      UJS::JavascriptProxies::JavascriptArgumentProxy.new(UJS::JavascriptProxies::ReferencedJavascriptElementProxy, generator, 'this')
    end
    
    # Returns a new JavascriptArgumentProxy for the event the behaviour has
    # been applied to.
    def event_proxy(generator)
      UJS::JavascriptProxies::JavascriptArgumentProxy.new(UJS::JavascriptProxies::JavascriptEventProxy, generator, 'event')
    end
    
    # Returns a new JavasScriptGenerator object
    def new_javascript_generator
      ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@template) {  }
    end
    
    def current_controller
      @controller
    end
    
    def normalise_behaviour_string(behaviour)
      behaviour << ';' unless behaviour =~ /;$/
      behaviour
    end
end