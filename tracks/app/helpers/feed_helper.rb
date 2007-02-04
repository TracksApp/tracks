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
    
  def format_ical_notes(notes)
    split_notes = notes.split(/\n/)
    joined_notes = split_notes.join("\\n")
  end
  
  def format_ical_uid(todo)
    sprintf("%s%s%s%s", request.protocol, request.host, request.port_string, todo_url(todo))
  end
  
end
