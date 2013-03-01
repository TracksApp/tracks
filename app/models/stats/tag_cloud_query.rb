module Stats
  class TagCloudQuery

    attr_reader :user, :cutoff
    def initialize(user, cutoff = nil)
      @user = user
      @cutoff = cutoff
    end

    def result
      Tag.find_by_sql(query_options)
    end

    def query_options
      options = [sql, user.id]
      options += [cutoff, cutoff] if cutoff
      options
    end

    def sql
      # TODO: parameterize limit
      query = "SELECT tags.id, tags.name AS name, count(*) AS count"
      query << " FROM taggings, tags, todos"
      query << " WHERE tags.id = tag_id"
      query << " AND todos.user_id=? "
      query << " AND taggings.taggable_type='Todo' "
      query << " AND taggings.taggable_id=todos.id "
      if cutoff
        query << " AND (todos.created_at > ? OR "
        query << "      todos.completed_at > ?) "
      end
      query << " GROUP BY tags.id, tags.name"
      query << " ORDER BY count DESC, name"
      query << " LIMIT 100"
    end

  end
end
