module ActionView::Helpers::PrototypeHelper
  
  class JavaScriptRef
    def initialize(ref); @ref = ref; end
    def to_json; @ref; end
  end
  
  def javascript_variable(name)
    JavaScriptRef.new(name)
  end
  
  def build_observer(klass, name, options={})
    set_default_external!(options)
    javascript = build_observer_js(klass, name, options)
    
    unless options.delete :external
      javascript_tag(javascript)
    else
      @controller.apply_behaviour("##{name}", javascript)
      return ''
    end
  end
  
  def build_observer_js(klass, name, options)
    if options[:with] && !options[:with].include?("=")
      options[:with] = "'#{options[:with]}=' + value"
    else
      options[:with] ||= 'value' if options[:update]
    end

    callback = options[:function] || remote_function(options)
    javascript  = "new #{klass}(#{name.to_json}, "
    javascript << "#{options[:frequency]}, " if options[:frequency]
    javascript << "function(element, value) {"
    javascript << "#{callback}}"
    javascript << ", '#{options[:on]}'" if options[:on]
    javascript << ")"
    javascript
  end
  
  def remote_function(options)
    javascript_options = options_for_ajax(options)

    update = ''
    if options[:update] and options[:update].is_a?Hash
      update  = []
      update << "success:'#{options[:update][:success]}'" if options[:update][:success]
      update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
      update  = '{' + update.join(',') + '}'
    elsif options[:update]
      update << "'#{options[:update]}'"
    end

    function = update.empty? ? 
      "new Ajax.Request(" :
      "new Ajax.Updater(#{update}, "

    url_options = options[:url]
    url_options = url_options.merge(:escape => false) if url_options.is_a? Hash
    url = url_options.is_a?(JavaScriptRef) ? url_options.to_json : "'#{url_for(url_options)}'"
    function << "#{url}"
    function << ", #{javascript_options})"

    function = "#{options[:before]}; #{function}" if options[:before]
    function = "#{function}; #{options[:after]}"  if options[:after]
    function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
    function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]

    return function
  end
  
end