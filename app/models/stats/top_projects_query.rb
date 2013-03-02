# Get the first 10 projects with their actions count of actions.
# When a cutoff is passed in, only actions that have been created
# or completed since that cutoff will be included.
module Stats
  class TopProjectsQuery

    attr_reader :user, :cutoff
    def initialize(user, cutoff = nil)
      @user = user
      @cutoff = cutoff
    end

    def result
      user.projects.find_by_sql(query_options)
    end

    private

    def query_options
      options = [sql, user.id]
      options += [cutoff, cutoff] if cutoff
      options
    end

    def sql
      query = "SELECT p.id, p.name, count(p.id) AS count "
      query << "FROM todos t, projects p "
      query << "WHERE t.project_id = p.id "
      query << "AND t.user_id= ? "
      if cutoff
        query << "AND (t.created_at > ? OR t.completed_at > ?) "
      end
      query << "GROUP BY p.id, p.name "
      query << "ORDER BY count DESC "
      query << "LIMIT 10"
    end

  end
end
