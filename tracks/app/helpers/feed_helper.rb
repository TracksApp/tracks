module FeedHelper

  # Build a nicely formatted text string for display
  # Context forms the heading, then the items are
  # indented underneath. If there is a due date
  # and the item is in a project, these are also displayed
  #
  def build_text_page(list,context)
    result_string = ""
    list.each do |item|
      if item.context_id == context.id
        result_string << "\n" + context.name.upcase + ":\n" if result_string.empty?
      
        if (item.completed?) && item.completed_at
          result_string << "    [Completed: " + format_date(item.completed_at) + "] "
        end
        
        if item.due
          result_string << "    [Due: " + format_date(item.due) + "] "
          result_string << item.description + " "
        else
          result_string << "    " + item.description + " "
        end

        if item.project_id
          result_string << "(" + item.project.name + ")"
        end
        result_string << "\n"
      end
    end
    return result_string
  end
  
  def build_projects_text_page(projects)
    result_string = ""
    projects.each do |p|
      result_string << "\n" + p.name.upcase + "\n"
    
		 	result_string << p.description + "\n" if p.description_present?
		 	result_string << "#{count_undone_todos(p)}. Project is #{p.state}.\n"
		 	result_string << "#{p.linkurl}\n" if p.linkurl_present?
		 	result_string << "\n"
	 	end
		
    return result_string
  end
  
  def build_contexts_text_page(contexts)
    result_string = ""
    contexts.each do |c|
      result_string << "\n" + c.name.upcase + "\n"
    
		 	result_string << "#{count_undone_todos(c)}. Context is #{c.hidden? ? 'Hidden' : 'Active'}.\n"
		 	result_string << "\n"
	 	end
		
    return result_string
  end
  
  def format_ical_notes(notes)
    split_notes = notes.split(/\n/)
    joined_notes = split_notes.join("\\n")
  end
  
  def format_ical_uid(todo)
    sprintf("%s%s%s%s", @request.protocol, @request.host, @request.port_string, url_for(:controller => 'todo', :action => 'show', :id => todo.id))
  end
  
  def rss_feed_link(options = {})
    image_tag = image_tag("feed-icon.png", :size => "16X16", :border => 0, :class => "rss-icon")
    linkoptions = {:controller => 'feed', :action => 'rss', :login => "#{@user.login}", :token => "#{@user.word}"}
    linkoptions.merge!(options)
		link_to(image_tag, linkoptions, :title => "RSS feed")
  end
  
  def text_feed_link(options = {})
    linkoptions = {:controller => 'feed', :action => 'text', :login => "#{@user.login}", :token => "#{@user.word}"}
    linkoptions.merge!(options)
    link_to('<span class="feed">TXT</span>', linkoptions, :title => "Plain text feed" )
  end
  
  def ical_feed_link(options = {})
    linkoptions = {:controller => 'feed', :action => 'ical', :login => "#{@user.login}", :token => "#{@user.word}"}
    linkoptions.merge!(options)
    link_to('<span class="feed">iCal</span>', linkoptions, :title => "iCal feed")
  end
  
  
end
