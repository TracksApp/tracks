class DataController < ApplicationController

  require 'csv'

  def index
    @page_title = "TRACKS::Export"
  end

  def import

  end

  def csv_map
    if params[:file].blank?
      flash[:notice] = "File can't be blank"
      redirect_to :back
    else
      @import_to = params[:import_to]

      begin
        #get column headers and format as [['name', column_number]...]
        i = -1
        @headers = import_headers(params[:file].path).collect { |v| [v, i+=1] }
        @headers.unshift ['',i]
      rescue Exception => e
        flash[:error] = "Invalid CVS: could not read headers: #{e}"
        redirect_to :back
        return
      end

      #save file for later
      begin
        uploaded_file = params[:file]
        @filename = Tracks::Utils.sanitize_filename(uploaded_file.original_filename)
        path_and_file = Rails.root.join('public', 'uploads', 'csv', @filename)
        File.open(path_and_file, "wb") { |f| f.write(uploaded_file.read) }
      rescue Exception => e
        flash[:error] = "Could not save uploaded CSV (#{path_and_file}). Can Tracks write to the upload directory? #{e}"
        redirect_to :back
        return
      end

      case @import_to
      when 'projects'
        @labels = [:name, :description]
      when 'todos'
        @labels = [:description, :context, :project, :notes, :created_at, :due, :completed_at]
      else
        flash[:error] = "Invalid import destination"
        redirect_to :back
      end
      respond_to do |format|
        format.html
      end
    end
  end

  def csv_import
    begin
      filename = Tracks::Utils.sanitize_filename(params[:file])
      path_and_file = Rails.root.join('public', 'uploads', 'csv', filename)
      case params[:import_to]
      when 'projects'
        count = Project.import path_and_file, params, current_user
        flash[:notice] = "#{count} Projects imported"
      when 'todos'
        count = Todo.import path_and_file, params, current_user
        flash[:notice] = "#{count} Todos imported"
      else
        flash[:error] = t('data.invalid_import_destination')
      end
    rescue Exception => e
      flash[:error] = t('data.invalid_import_destination') + ": #{e}"
    end
    File.delete(path_and_file)
    redirect_to import_data_path
  end

  def import_headers(file)
    CSV.foreach(file, headers: false) do |row|
      return row
    end
  end

  def export
    # Show list of formats for export
  end

  # Thanks to a tip by Gleb Arshinov
  # <http://lists.rubyonrails.org/pipermail/rails/2004-November/000199.html>
  def yaml_export
    all_tables = {}

    all_tables['todos'] = current_user.todos.includes(:tags).load
    all_tables['contexts'] = current_user.contexts.load
    all_tables['projects'] = current_user.projects.load

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

    all_tables['tags'] = tags.load
    all_tables['taggings'] = taggings.load
    all_tables['notes'] = current_user.notes.load
    all_tables['recurring_todos'] = current_user.recurring_todos.load

    result = all_tables.to_yaml
    result.gsub!(/\n/, "\r\n")   # TODO: general functionality for line endings
    send_data(result, :filename => "tracks_backup.yml", :type => 'text/plain')
  end

  # export all actions as csv
  def csv_actions
    content_type = 'text/csv'
    CSV.generate(result = "") do |csv|
      csv << ["id", "Context", "Project", "Description", "Notes", "Tags",
        "Created at", "Due", "Completed at", "User ID", "Show from",
        "state"]
      current_user.todos.includes(:context, :project, :taggings, :tags).each do |todo|
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

  # export all notes as csv
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
