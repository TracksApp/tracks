module Todos
  class UndoneTodosQuery
    include ActionView::Helpers::SanitizeHelper

    attr_reader :current_user
    def initialize(current_user)
      @current_user = current_user
    end

    def query(params)
      if params[:done]
        not_done_todos = current_user.todos.completed.completed_after(Time.zone.now - params[:done].to_i.days)
      else
        not_done_todos = current_user.todos.active.not_hidden
      end

      not_done_todos = not_done_todos.
        reorder(Arel.sql("todos.due IS NULL, todos.due ASC, todos.created_at ASC"))
        .includes(Todo::DEFAULT_INCLUDES)

      not_done_todos = not_done_todos.limit(sanitize(params[:limit])) if params[:limit]

      if params[:due]
        due_within_when = Time.zone.now + params[:due].to_i.days
        not_done_todos = not_done_todos.where('todos.due <= ?', due_within_when)
      end

      if params[:tag]
        tag = Tag.where(:name => params[:tag]).first
        return [] if !tag
        not_done_todos = not_done_todos.joins(:taggings).where('taggings.tag_id = ?', tag.id)
      end

      if params[:context_id]
        context = current_user.contexts.find(params[:context_id])
        not_done_todos = not_done_todos.where('context_id' => context.id)
      end

      if params[:project_id]
        project = current_user.projects.find(params[:project_id])
        not_done_todos = not_done_todos.where('project_id' => project)
      end

      return not_done_todos
    end
  end
end
