module ActionView::Helpers::ScriptaculousHelper  
  def draggable_element(element_id, options={})
    set_default_external!(options)
    external = options.delete :external
    prepare_script(element_id, draggable_element_js(element_id, options).chop!, external)
  end
  
  def draggable_element_js(element_id, options = {}) #:nodoc:
    %(new Draggable(#{element_id.to_json}, #{options_for_javascript(options)});)
  end
  
  def drop_recieving_element(element_id, options={})
    set_default_external!(options)
    external = options.delete :external
    prepare_script(element_id, drop_receiving_element_js(element_id, options).chop!, external)
  end
  
  def drop_receiving_element_js(element_id, options = {}) #:nodoc:
    options[:with]     ||= "'id=' + encodeURIComponent(element.id)"
    options[:onDrop]   ||= "function(element){" + remote_function(options) + "}"
    options.delete_if { |key, value| ActionView::Helpers::PrototypeHelper::AJAX_OPTIONS.include?(key) }

    options[:accept] = array_or_string_for_javascript(options[:accept]) if options[:accept]    
    options[:hoverclass] = "'#{options[:hoverclass]}'" if options[:hoverclass]
    
    %(Droppables.add(#{element_id.to_json}, #{options_for_javascript(options)});)
  end
  
  def sortable_element(element_id, options={})
    set_default_external!(options)
    external = options.delete :external
    prepare_script(element_id, sortable_element_js(element_id, options).chop!, external)
  end
  
  def sortable_element_js(element_id, options = {}) #:nodoc:
    options[:with]     ||= "Sortable.serialize(#{element_id.to_json})"
    options[:onUpdate] ||= "function(){" + remote_function(options) + "}"
    options.delete_if { |key, value| ActionView::Helpers::PrototypeHelper::AJAX_OPTIONS.include?(key) }

    [:tag, :overlap, :constraint, :handle].each do |option|
      options[option] = "'#{options[option]}'" if options[option]
    end

    options[:containment] = array_or_string_for_javascript(options[:containment]) if options[:containment]
    options[:only] = array_or_string_for_javascript(options[:only]) if options[:only]

    %(Sortable.create(#{element_id.to_json}, #{options_for_javascript(options)});)
  end
  
  protected
  
  def prepare_script(element_id, js, external=true)
    unless external
      javascript_tag(js)
    else
      @controller.apply_behaviour "##{element_id}", js
      return ''
    end
  end
  
end

