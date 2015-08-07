module Stats
  class Totals

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def empty?
      actions.empty?
    end

    def tags
      @tags ||= tag_ids.size
    end

    def unique_tags
      @unique_tags ||= tag_ids.uniq.size
    end

    def first_action_at
      first_action.try(:created_at)
    end

    def projects
      user.projects.count
    end

    def active_projects
      user.projects.active.count
    end

    def hidden_projects
      user.projects.hidden.count
    end

    def completed_projects
      user.projects.completed.count
    end

    def contexts
      user.contexts.count
    end

    def visible_contexts
      user.contexts.active.count
    end

    def hidden_contexts
      user.contexts.hidden.count
    end

    def all_actions
      actions.count
    end

    def completed_actions
      actions.completed.count
    end

    def incomplete_actions
      actions.not_completed.count
    end

    def deferred_actions
      actions.deferred.count
    end

    def blocked_actions
      actions.blocked.count
    end

    private

    def actions
      user.todos
    end

    def first_action
      @first_action ||= user.todos.reorder("created_at ASC").first
    end

    def tag_ids
      @tag_ids ||= Stats::UserTagsQuery.new(user).result.map(&:id)
    end

  end
end
