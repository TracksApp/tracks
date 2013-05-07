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
    
    all_tables['todos'] = current_user.todos.includes(:tags).all
    all_tables['contexts'] = current_user.contexts.all
    all_tables['projects'] = current_user.projects.all

    todo_tag_ids = Tag.find_by_sql([
        "SELECT DISTINCT tags.id "+
          "FROM tags, taggings, todos "+
          "WHERE todos.user_id=? "+
          "AND tags.id = taggings.tag_id " +
          "AND taggings.taggable_id = todos.id ", current_user.id])
    rec_todo_tag_ids = Tag.find_by_sql([
        "SELECT DISTINCT tags.id "+
          "FROM tags, taggings, recurring_todos "+
          "WHERE recurring_todos.user_id=? "+
          "AND tags.id = taggings.tag_id " +
          "AND taggings.taggable_id = recurring_todos.id ", current_user.id])
    tags = Tag.where("id IN (?) OR id IN (?)", todo_tag_ids, rec_todo_tag_ids)
    taggings = Tagging.where("tag_id IN (?) OR tag_id IN(?)", todo_tag_ids, rec_todo_tag_ids)

    all_tables['tags'] = tags.all
    all_tables['taggings'] = taggings.all
    all_tables['notes'] = current_user.notes.all
    all_tables['recurring_todos'] = current_user.recurring_todos.all
    
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
      current_user.todos.include(:context, :project).all.each do |todo|
        csv << [todo.id, todo.context.name,
          todo.project_id.nil? ? "" : todo.project.name,
          todo.description,
          todo.notes, todo.tags.collect{|t| t.name}.join(', '),
          todo.created_at.to_formatted_s(:db),
          todo.due? ? todo.due.to_formatted_s(:db) : "",
          todo.completed_at? ? todo.completed_at.to_formatted_s(:db) : "",
          todo.user_id,
          todo.show_from? ? todo.show_from.to_formatted_s(:db) : "",
          todo.state]
      end
    end
    send_data(result, :filename => "todos.csv", :type => content_type)
  end

  
  def csv_notes
    content_type = 'text/csv'
    CSV.generate(result = "") do |csv|
      csv << ["id", "User ID", "Project", "Note",
        "Created at", "Updated at"]
      # had to remove project include because it's association order is leaking
      # through and causing an ambiguous column ref even with_exclusive_scope
      # didn't seem to help -JamesKebinger
      current_user.notes.reorder("notes.created_at").each do |note|
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
    todo_tag_ids = Tag.find_by_sql([
        "SELECT DISTINCT tags.id "+
          "FROM tags, taggings, todos "+
          "WHERE todos.user_id=? "+
          "AND tags.id = taggings.tag_id " +
          "AND taggings.taggable_id = todos.id ", current_user.id])
    rec_todo_tag_ids = Tag.find_by_sql([
        "SELECT DISTINCT tags.id "+
          "FROM tags, taggings, recurring_todos "+
          "WHERE recurring_todos.user_id=? "+
          "AND tags.id = taggings.tag_id " +
          "AND taggings.taggable_id = recurring_todos.id ", current_user.id])
    tags = Tag.where("id IN (?) OR id IN (?)", todo_tag_ids, rec_todo_tag_ids)
    taggings = Tagging.where("tag_id IN (?) OR tag_id IN(?)", todo_tag_ids, rec_todo_tag_ids)

    result = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><tracks_data>"
    result << current_user.todos.to_xml(:skip_instruct => true)
    result << current_user.contexts.to_xml(:skip_instruct => true)
    result << current_user.projects.to_xml(:skip_instruct => true)
    result << tags.to_xml(:skip_instruct => true)
    result << taggings.to_xml(:skip_instruct => true)
    result << current_user.notes.to_xml(:skip_instruct => true)
    result << current_user.recurring_todos.to_xml(:skip_instruct => true)
    result << "</tracks_data>"
    send_data(result, :filename => "tracks_data.xml", :type => 'text/xml')
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
    raise "YAML loading is disabled" 
  end
  
end