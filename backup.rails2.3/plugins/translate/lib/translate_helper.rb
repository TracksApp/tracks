module TranslateHelper
  def simple_filter(labels, param_name = 'filter', selected_value = nil)
    selected_value ||= params[param_name]
    filter = []
    labels.each do |item|
      if item.is_a?(Array)
        type, label = item
      else
        type = label = item
      end
      if type.to_s == selected_value.to_s
        filter << "<i>#{label}</i>"
      else
        link_params = params.merge({param_name.to_s => type})
        link_params.merge!({"page" => nil}) if param_name.to_s != "page"
        filter << link_to(label, link_params)
      end
    end
    filter.join(" | ")    
  end

  def n_lines(text, line_size)
    n_lines = 1
    if text.present?
      n_lines = text.split("\n").size
      if n_lines == 1 && text.length > line_size
        n_lines = text.length / line_size + 1
      end
    end
    n_lines
  end
  
  def translate_javascript_includes
    sources = []
    if File.exists?(File.join(Rails.root, "public", "javascripts", "prototype.js"))
      sources << "/javascripts/prototype.js"
    else
      sources << "http://ajax.googleapis.com/ajax/libs/prototype/1.6.1.0/prototype.js"
    end
    sources << "http://www.google.com/jsapi"
    sources.map do |src|
      %Q{<script src="#{src}" type="text/javascript"></script>}
    end.join("\n")
  end
end
