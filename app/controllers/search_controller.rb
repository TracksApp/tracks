class SearchController < ApplicationController

  helper :todos, :application, :notes, :projects  
  
  def results
    @source_view = params['_source_view'] || 'search'
    @page_title = "TRACKS::Search Results for #{params[:search]}"
    terms = '%' + params[:search] + '%'
    @found_todos = current_user.todos.find(:all, :conditions => ["todos.description LIKE ? OR todos.notes LIKE ?", terms, terms], :include => [:tags, :project, :context])
    @found_projects = current_user.projects.find(:all, :conditions => ["name LIKE ? or description LIKE ?", terms, terms])
    @found_notes = current_user.notes.find(:all, :conditions => ["body LIKE ?", terms])
 
    @count = @found_todos.size  + @found_projects.size + @found_notes.size
   
    init_not_done_counts(['project'])
    init_project_hidden_todo_counts(['project'])
  end

  def index
    @page_title = "TRACKS::Search"    
  end
  
  def init
    @source_view = params['_source_view'] || 'search'
  end

end
