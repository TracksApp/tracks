# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Convert a date object to the format specified
  # in config/settings.yml
  #
  def format_date(date)
    if date
      date_format = @user.preference.date_format
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
  
  # Replicates the link_to method but also checks request.request_uri to find
  # current page. If that matches the url, the link is marked
  # id = "current"
  #
  def navigation_link(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)    
    id_tag = (request.request_uri == url) ? " id=\"current\"" : ""
    
    "<a href=\"#{url}\"#{tag_options}#{id_tag}>#{name || url}</a>"
  end
  
  # Check due date in comparison to today's date
  # Flag up date appropriately with a 'traffic light' colour code
  #
  def due_date(due)
    if due == nil
      return ""
    end

    @now = Date.today
    @days = due-@now
       
    case @days
      # overdue or due very soon! sound the alarm!
      when -1000..-1
        "<a title='" + format_date(due) + "'><span class=\"red\">Overdue by " + (@days * -1).to_s + " days</span></a> "
      when 0
           "<a title='" + format_date(due) + "'><span class=\"amber\">Due Today</span></a> "
      when 1
           "<a title='" + format_date(due) + "'><span class=\"amber\">Due Tomorrow</span></a> "
      # due 2-7 days away
      when 2..7
      if @user.preference.due_style == "1"
        "<a title='" + format_date(due) + "'><span class=\"orange\">Due on " + due.strftime("%A") + "</span></a> "
      else
        "<a title='" + format_date(due) + "'><span class=\"orange\">Due in " + @days.to_s + " days</span></a> "
      end
      # more than a week away - relax
      else
        "<a title='" + format_date(due) + "'><span class=\"green\">Due in " + @days.to_s + " days</span></a> "
    end
  end

  # Check due date in comparison to today's date
  # Flag up date appropriately with a 'traffic light' colour code
  # Modified method for mobile screen
  #
  def due_date_mobile(due)
    if due == nil
      return ""
    end

    @now = Date.today
    @days = due-@now
       
    case @days
      # overdue or due very soon! sound the alarm!
      when -1000..-1
        "<span class=\"red\">" + format_date(due) +"</span>"
      when 0
           "<span class=\"amber\">"+ format_date(due) + "</span>"
      when 1
           "<span class=\"amber\">" + format_date(due) + "</span>"
      # due 2-7 days away
      when 2..7
          "<span class=\"orange\">" + format_date(due) + "</span>"
     # more than a week away - relax
      else
        "<span class=\"green\">" + format_date(due) + "</span>"
    end
  end
  
  # Returns a count of next actions in the given context or project
  # The result is count and a string descriptor, correctly pluralised if there are no
  # actions or multiple actions
  #
  def count_undone_todos(todos_parent, string="actions")
    if (todos_parent.is_a?(Project) && todos_parent.hidden?)
      count = eval "@project_project_hidden_todo_counts[#{todos_parent.id}]"
    else
      count = eval "@#{todos_parent.class.to_s.downcase}_not_done_counts[#{todos_parent.id}]"
    end
    count = 0 if count == nil
    #count = todos_parent.todos.select{|t| !t.done }.size
    if count == 1
      word = string.singularize
    else
      word = string.pluralize
    end
    return count.to_s + " " + word
  end
  
  def link_to_context(context, descriptor = sanitize(context.name))
    link_to( descriptor, { :controller => "context", :action => "show", :url_friendly_name => context.url_friendly_name }, :title => "View context: #{context.name}" )
  end
  
  def link_to_project(project, descriptor = sanitize(project.name))
    link_to( descriptor, { :controller => "project", :action => "show", :url_friendly_name => project.url_friendly_name }, :title => "View project: #{project.name}" )
  end
  
  def item_link_to_context(item)
    descriptor = "[C]"
    descriptor = "[#{item.context.name}]" if (@user.preference.verbose_action_descriptors)
    link_to_context( item.context, descriptor )
  end
  
  def item_link_to_project(item)
    descriptor = "[P]"
    descriptor = "[#{item.project.name}]" if (@user.preference.verbose_action_descriptors)
    link_to_project( item.project, descriptor )
  end
  
  def render_flash
    render :partial => 'shared/flash', :locals => { :flash => flash }
  end
  
  # Display a flash message in RJS templates
  # Usage: page.notify :warning, "This is the message", 5.0
  # Puts the message into a flash of type 'warning', fades over 5 secs
  def notify(type, message, fade_duration)
    type = type.to_s  # symbol to string
    page.replace 'flash', "<h4 id='flash' class='alert #{type}'>#{message}</h4>" 
    page.visual_effect :fade, 'flash', :duration => fade_duration
  end
  
end
