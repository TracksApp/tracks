# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Convert a date object to the format specified
  # in config/settings.yml
  #
  def format_date(date)
    if date
      date_format = @user.preferences["date_format"]
      formatted_date = date.strftime("#{date_format}")
    else
      formatted_date = ''
    end
  end

  # Uses RedCloth to transform text using either Textile or Markdown
  # Need to require redcloth above
  # RedCloth 3.0 or greater is needed to use Markdown, otherwise it only handles Textile
  #
  def markdown(text)
    RedCloth.new(text).to_html
  end

  # Wraps object in HTML tags, tag
  #
  def tag_object(object, tag)
    tagged = "<#{tag}>#{object}</#{tag}>"
  end

  # Converts names to URL-friendly format by substituting underscores for spaces
  #
  def urlize(name)
      name.to_s.gsub(/ /, "_")
  end
  
  # Replicates the link_to method but also checks request.request_uri to find
  # current page. If that matches the name parameter, the link is marked
  # id = "current"
  #
  def navigation_link(name, options = {}, html_options = nil, *parameters_for_method_reference)
    curr_path = request.request_uri.to_s
    if curr_path =~ /([a-z]+)$/
      curr_page = $&
    elsif curr_path == "/"
      curr_page = "home"
    end
    
    id_tag = (curr_page == name.downcase) ? " id=\"current\"" : ""
    
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    "<a href=\"#{url}\"#{tag_options}#{id_tag}>#{name || url}</a>"
  end
end
