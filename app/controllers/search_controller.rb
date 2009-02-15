class SearchController < ApplicationController

  helper :todos, :application, :notes, :projects  
  
  def results
    @source_view = params['_source_view'] || 'search'
    @page_title = "TRACKS::Search Results for #{params[:search]}"
    terms = '%' + params[:search] + '%'
    @found_todos = current_user.todos.find(:all, :conditions => ["todos.description LIKE ? OR todos.notes LIKE ?", terms, terms], :include => [:tags, :project, :context])
    @found_projects = current_user.projects.find(:all, :conditions => ["name LIKE ? OR description LIKE ?", terms, terms])
    @found_notes = current_user.notes.find(:all, :conditions => ["body LIKE ?", terms])
    @found_contexts = current_user.contexts.find(:all, :conditions => ["name LIKE ?", terms])
    # TODO: limit search to tags on todos
    @found_tags = Tagging.find_by_sql([
        "SELECT DISTINCT tags.name as name "+
          "FROM tags "+
          "LEFT JOIN taggings ON tags.id = taggings.tag_id "+
          "LEFT JOIN todos ON taggings.taggable_id = todos.id "+
          "WHERE todos.user_id=? "+
          "AND tags.name LIKE ? ", current_user.id, terms])
 
    @count = @found_todos.size  + @found_projects.size + @found_notes.size + @found_contexts.size + @found_tags.size
   
    init_not_done_counts
    init_project_hidden_todo_counts
  end

  def index
    @page_title = "TRACKS::Search"    
  end
  
  def init
    @source_view = params['_source_view'] || 'search'
  end

end
