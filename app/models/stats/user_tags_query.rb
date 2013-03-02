module Stats
  class UserTagsQuery

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def result
      user.todos.find_by_sql([sql, user.id])
    end

    private

    def sql
      <<-SQL
        SELECT tags.id as id
        FROM tags, taggings, todos
        WHERE tags.id = taggings.tag_id
        AND taggings.taggable_id = todos.id
        AND todos.user_id = ?
      SQL
    end

  end
end
