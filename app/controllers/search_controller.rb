class SearchController < ApplicationController

  helper :todos, :application, :notes, :projects, :contexts
  
  def results
    @source_view = params['_source_view'] || 'search'
    @page_title = "TRACKS::Search Results for #{params[:search]}"
    terms = "%#{params[:search]}%"

    @found_not_complete_todos = incomplete_todos(terms)
    @found_complete_todos = complete_todos(terms)
    @found_todos = @found_not_complete_todos + @found_complete_todos

    @found_projects = current_user.projects.with_name_or_description(terms);
    @found_notes = current_user.notes.with_body(terms);
    @found_contexts = current_user.contexts.with_name(terms)
    
    # TODO: limit search to tags on todos
    @found_tags = todo_tags_by_name(current_user, terms)
    @count = @found_todos.size  + @found_projects.size + @found_notes.size + @found_contexts.size + @found_tags.size

    init_not_done_counts
    init_project_hidden_todo_counts
  end

  def index
    @page_title = "TRACKS::Search"
  end

private
  def incomplete_todos(terms)
    current_user.todos.
      where("(todos.description LIKE ? OR todos.notes LIKE ?) AND todos.completed_at IS NULL", terms, terms).
      includes(Todo::DEFAULT_INCLUDES).
      reorder("todos.due IS NULL, todos.due ASC, todos.created_at ASC")
  end

  def complete_todos(terms)
    current_user.todos.
      where("(todos.description LIKE ? OR todos.notes LIKE ?) AND NOT (todos.completed_at IS NULL)", terms, terms).
      includes(Todo::DEFAULT_INCLUDES).
      reorder("todos.completed_at DESC")
  end

  def todo_tags_by_name(current_user, terms)
    Tagging.find_by_sql([
        "SELECT DISTINCT tags.name as name "+
          "FROM tags "+
          "LEFT JOIN taggings ON tags.id = taggings.tag_id "+
          "LEFT JOIN todos ON taggings.taggable_id = todos.id "+
          "WHERE todos.user_id=? "+
          "AND tags.name LIKE ? ", current_user.id, terms])

  end
end
