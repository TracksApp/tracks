module Search

  class SearchResults
    attr_reader :results

    def initialize(user, terms)
      @user = user
      @terms = "%#{terms}%"
      @results = {}
    end

    def search
      results[:not_complete_todos] = incomplete_todos(@terms)
      results[:complete_todos]     = complete_todos(@terms)
      results[:todos]              = results[:not_complete_todos] + results[:complete_todos]
      results[:projects]           = @user.projects.with_name_or_description(@terms)
      results[:notes]              = @user.notes.with_body(@terms)
      results[:contexts]           = @user.contexts.with_name(@terms)
      results[:tags]               = todo_tags_by_name(@terms)
    end

    def number_of_finds
      results[:todos].size  + results[:projects].size + results[:notes].size + results[:contexts].size + results[:tags].size
    end

    private

    def incomplete_todos(terms)
      @user.todos.
        where("(todos.description LIKE ? OR todos.notes LIKE ?) AND todos.completed_at IS NULL", terms, terms).
        includes(Todo::DEFAULT_INCLUDES).
        reorder("todos.due IS NULL, todos.due ASC, todos.created_at ASC")
    end

    def complete_todos(terms)
      @user.todos.
        where("(todos.description LIKE ? OR todos.notes LIKE ?) AND NOT (todos.completed_at IS NULL)", terms, terms).
        includes(Todo::DEFAULT_INCLUDES).
        reorder("todos.completed_at DESC")
    end

    def todo_tags_by_name(terms)
      Tagging.find_by_sql([
          "SELECT DISTINCT tags.name as name "+
            "FROM tags "+
            "LEFT JOIN taggings ON tags.id = taggings.tag_id "+
            "LEFT JOIN todos ON taggings.taggable_id = todos.id "+
            "WHERE todos.user_id=? "+
            "AND tags.name LIKE ? ", @user.id, terms])
    end

  end

end
