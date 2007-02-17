# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Convert a date object to the format specified
  # in config/settings.yml
  #
  def format_date(date)
    if date
      date_format = @user.prefs.date_format
      formatted_date = @user.prefs.tz.adjust(date).strftime("#{date_format}")
    else
      formatted_date = ''
    end
    formatted_date
  end
  
  def user_time
    @user.prefs.tz.adjust(Time.now.utc)
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
  
  def days_from_today(date)
    today = Time.now.utc.to_date
    @user.prefs.tz.adjust(date).to_date - @user.prefs.tz.adjust(today).to_date
  end
  
  # Check due date in comparison to today's date
  # Flag up date appropriately with a 'traffic light' colour code
  #
  def due_date(due)
    if due == nil
      return ""
    end

    days = days_from_today(due)
       
    case days
      # overdue or due very soon! sound the alarm!
      when -1000..-1
        "<a title='#{format_date(due)}'><span class=\"red\">Overdue by #{pluralize(days * -1, 'day')}</span></a> "
      when 0
           "<a title='#{format_date(due)}'><span class=\"amber\">Due Today</span></a> "
      when 1
           "<a title='#{format_date(due)}'><span class=\"amber\">Due Tomorrow</span></a> "
      # due 2-7 days away
      when 2..7
      if @user.prefs.due_style == "1"
        "<a title='#{format_date(due)}'><span class=\"orange\">Due on #{due.strftime("%A")}</span></a> "
      else
        "<a title='#{format_date(due)}'><span class=\"orange\">Due in #{pluralize(days, 'day')}</span></a> "
      end
      # more than a week away - relax
      else
        "<a title='#{format_date(due)}'><span class=\"green\">Due in #{pluralize(days, 'day')}</span></a> "
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

    days = days_from_today(due)
       
    case days
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
    @controller.count_undone_todos(todos_parent, string)
  end

  def count_undone_todos_text(todos_parent, string="actions")
    count_undone_todos(todos_parent, string).gsub("&nbsp;"," ")
  end
  
  def link_to_context(context, descriptor = sanitize(context.name))
    link_to( descriptor, context_path(context), :title => "View context: #{context.name}" )
  end
  
  def link_to_project(project, descriptor = sanitize(project.name))
    link_to( descriptor, project_path(project), :title => "View project: #{project.name}" )
  end
  
  def item_link_to_context(item)
    descriptor = "[C]"
    descriptor = "[#{item.context.name}]" if (@user.prefs.verbose_action_descriptors)
    link_to_context( item.context, descriptor )
  end
  
  def item_link_to_project(item)
    descriptor = "[P]"
    descriptor = "[#{item.project.name}]" if (@user.prefs.verbose_action_descriptors)
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
