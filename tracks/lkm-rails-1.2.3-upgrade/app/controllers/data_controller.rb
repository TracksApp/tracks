class DataController < ApplicationController
  
  require 'csv'
  
  def index
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
    
    all_tables['todos'] = @user.todos.find(:all)
    all_tables['contexts'] = @user.contexts.find(:all)
    all_tables['projects'] = @user.projects.find(:all)
    all_tables['notes'] = @user.notes.find(:all)
    
    result = all_tables.to_yaml
    result.gsub!(/\n/, "\r\n")   # TODO: general functionality for line endings
    send_data(result, :filename => "tracks_backup.yml", :type => 'text/plain')
  end
  
  def csv_actions
    content_type = 'text/csv'
    CSV::Writer.generate(result = "") do |csv|
      csv << ["ID", "Context", "Project", "Description", "Notes",
              "Created at", "Due", "Completed at", "User ID", "Show from",
              "state"]
      @user.todos.find(:all, :include => [:context, :project]).each do |todo|
        # Format dates in ISO format for easy sorting in spreadsheet
        # Print context and project names for easy viewing
        csv << [todo.id, todo.context.name, 
                todo.project_id = todo.project_id.nil? ? "" : todo.project.name,
                todo.description, 
                todo.notes, todo.created_at.to_formatted_s(:db),
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
      csv << ["ID", "User ID", "Project", "Note",
              "Created at", "Updated at"]
      @user.notes.find(:all, :include => [:project]).each do |note|
        # Format dates in ISO format for easy sorting in spreadsheet
        # Print context and project names for easy viewing
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
    result << @user.todos.find(:all).to_xml
    result << @user.contexts.find(:all).to_xml(:skip_instruct => true)
    result << @user.projects.find(:all).to_xml(:skip_instruct => true)
    result << @user.notes.find(:all).to_xml(:skip_instruct => true)
    send_data(result, :filename => "tracks_backup.xml", :type => 'text/xml')
  end
  
  def yaml_form
    # Draw the form to input the YAML text data
  end

  def yaml_import
    # Logic to load the YAML text file and create new records from data
  end
 
end
