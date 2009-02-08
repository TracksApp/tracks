class DataController < ApplicationController
  
  require 'csv'
  
  def index
    @page_title = "TRACKS::Export"
  end

  def import
  end

  def export
    # Show list of formats for export
  end
  
  # Thanks to a tip by Gleb Arshinov
  # <http://lists.rubyonrails.org/pipermail/rails/2004-November/000199.html>
  def yaml_export
    all_tables = {}
    
    all_tables['todos'] = current_user.todos.find(:all)
    all_tables['contexts'] = current_user.contexts.find(:all)
    all_tables['projects'] = current_user.projects.find(:all)

    tags = Tag.find_by_sql([
        "SELECT tags.* "+
          "FROM tags, taggings, todos "+
          "WHERE todos.user_id=? "+
          "AND tags.id = taggings.tag_id " +
          "AND taggings.taggable_id = todos.id ", current_user.id])
    all_tables['tags'] = tags

    taggings = Tagging.find_by_sql([
        "SELECT taggings.* "+
          "FROM taggings, todos "+
          "WHERE todos.user_id=? "+
          "AND taggings.taggable_id = todos.id ", current_user.id])
    all_tables['taggings'] = taggings

    all_tables['notes'] = current_user.notes.find(:all)
    all_tables['recurring_todos'] = current_user.recurring_todos.find(:all)
    
    result = all_tables.to_yaml
    result.gsub!(/\n/, "\r\n")   # TODO: general functionality for line endings
    send_data(result, :filename => "tracks_backup.yml", :type => 'text/plain')
  end
  
  def csv_actions
    content_type = 'text/csv'
    CSV::Writer.generate(result = "") do |csv|
      csv << ["id", "Context", "Project", "Description", "Notes", "Tags",
        "Created at", "Due", "Completed at", "User ID", "Show from",
        "state"]
      current_user.todos.find(:all, :include => [:context, :project]).each do |todo|
        # Format dates in ISO format for easy sorting in spreadsheet Print
        # context and project names for easy viewing
        csv << [todo.id, todo.context.name, 
          todo.project_id = todo.project_id.nil? ? "" : todo.project.name,
          todo.description, 
          todo.notes, todo.tags.collect{|t| t.name}.join(', '),
          todo.created_at.to_formatted_s(:db),
          todo.due = todo.due? ? todo.due.to_formatted_s(:db) : "",
          todo.completed_at = todo.completed_at? ? todo.completed_at.to_formatted_s(:db) : "", 
          todo.user_id, 
          todo.show_from = todo.show_from? ? todo.show_from.to_formatted_s(:db) : "",
          todo.state] 
      end
    end
    send_data(result, :filename => "todos.csv", :type => content_type)
  end
  
  def csv_notes
    content_type = 'text/csv'
    CSV::Writer.generate(result = "") do |csv|
      csv << ["id", "User ID", "Project", "Note",
        "Created at", "Updated at"]
      # had to remove project include because it's association order is leaking
      # through and causing an ambiguous column ref even with_exclusive_scope
      # didn't seem to help -JamesKebinger
      current_user.notes.find(:all,:order=>"notes.created_at").each do |note|
        # Format dates in ISO format for easy sorting in spreadsheet Print
        # context and project names for easy viewing
        csv << [note.id, note.user_id, 
          note.project_id = note.project_id.nil? ? "" : note.project.name,
          note.body, note.created_at.to_formatted_s(:db),
          note.updated_at.to_formatted_s(:db)] 
      end
    end
    send_data(result, :filename => "notes.csv", :type => content_type)
  end
  
  def xml_export
    result = ""
    result << current_user.todos.find(:all).to_xml
    result << current_user.contexts.find(:all).to_xml(:skip_instruct => true)
    result << current_user.projects.find(:all).to_xml(:skip_instruct => true)
    result << current_user.tags.find(:all).to_xml(:skip_instruct => true)
    result << current_user.taggings.find(:all).to_xml(:skip_instruct => true)
    result << current_user.notes.find(:all).to_xml(:skip_instruct => true)
    result << current_user.recurring_todos.find(:all).to_xml(:skip_instruct => true)
    send_data(result, :filename => "tracks_backup.xml", :type => 'text/xml')
  end
  
  def yaml_form
    # Draw the form to input the YAML text data
  end

  # adjusts time to utc
  def adjust_time(timestring)
    if (timestring=='') or ( timestring == nil)
      return nil
    else 
      return Time.parse(timestring + 'UTC')
    end
  end

  def yaml_import
    @errmessage = ''
    @inarray = YAML::load(params['import']['yaml'])
    # arrays to handle id translations

    # contexts
    translate_context = Hash.new
    translate_context[nil] = nil
    current_user.contexts.each { |context| context.destroy }
    @inarray['contexts'].each { | item |
      newitem = Context.new(item.ivars['attributes'])
      newitem.user_id = current_user.id
      newitem.created_at = adjust_time(item.ivars['attributes']['created_at'])
      newitem.save(false)
      translate_context[item.ivars['attributes']['id'].to_i] = newitem.id
    }

    # projects
    translate_project = Hash.new
    translate_project[nil] = nil
    current_user.projects.each { |item| item.destroy }
    @inarray['projects'].each { |item|
      newitem = Project.new(item.ivars['attributes'])
      # ids
      newitem.user_id = current_user.id
      newitem.default_context_id = translate_context[newitem.default_context_id]
      newitem.save(false)
      translate_project[item.ivars['attributes']['id'].to_i] = newitem.id

      # state + dates
      newitem.transition_to(item.ivars['attributes']['state'])
      newitem.completed_at = adjust_time(item.ivars['attributes']['completed_at'])
      newitem.created_at = adjust_time(item.ivars['attributes']['created_at'])
      newitem.position = item.ivars['attributes']['position']
      newitem.save(false)
    }

    # todos
    translate_todo = Hash.new
    translate_todo[nil] = nil
    current_user.todos.each { |item| item.destroy }
    @inarray['todos'].each { |item|
      newitem = Todo.new(item.ivars['attributes'])
      # ids
      newitem.user_id = current_user.id
      newitem.context_id = translate_context[newitem.context_id]
      newitem.project_id = translate_project[newitem.project_id]
      # TODO: vyresit recurring_todo_id
      newitem.save(false)
      translate_todo[item.ivars['attributes']['id'].to_i] = newitem.id

      # state + dates
      case item.ivars['attributes']['state']
      when 'active' then newitem.activate!
      when 'project_hidden' then newitem.hide!
      when 'completed' 
        newitem.complete!
        newitem.completed_at = adjust_time(item.ivars['attributes']['completed_at'])
      when 'deferred' then newitem.defer!
      end
      newitem.created_at = adjust_time(item.ivars['attributes']['created_at'])
      newitem.save(false)
    }

    # tags
    translate_tag = Hash.new
    translate_tag[nil] = nil
    current_user.tags.each { |item| item.destroy }
    @inarray['tags'].each { |item|
      newitem = Tag.new(item.ivars['attributes'])
      newitem.created_at = adjust_time(item.ivars['attributes']['created_at'])
      newitem.save
      translate_tag[item.ivars['attributes']['id'].to_i] = newitem.id
    }

    # taggings
    current_user.taggings.each { |item| item.destroy }
    @inarray['taggings'].each { |item|
      newitem = Tagging.new(item.ivars['attributes'])
      newitem.user_id = current_user.id
      newitem.tag_id = translate_tag[newitem.tag_id]
      case newitem.taggable_type
      when 'Todo' then newitem.taggable_id = translate_todo[newitem.taggable_id]
      else newitem.taggable_id = 0
      end
      newitem.save
    }

    # notes
    current_user.notes.each { |item| item.destroy }
    @inarray['notes'].each { |item|
      newitem = Note.new(item.ivars['attributes'])
      newitem.id = item.ivars['attributes']['id']
      newitem.user_id = current_user.id
      newitem.project_id = translate_project[newitem.project_id]
      newitem.created_at = adjust_time(item.ivars['attributes']['created_at'])
      newitem.save
    }
  end
  
end