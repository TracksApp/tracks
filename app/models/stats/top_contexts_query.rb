# Get action count for the top n contexts (default: all)
# If initialized with :running => true, then only active
# and visible contexts will be included.
module Stats
  class TopContextsQuery

    attr_reader :user, :running, :limit
    def initialize(user, options = {})
      @user = user
      @running = options.fetch(:running) { false }
      @limit = options.fetch(:limit) { false }
    end

    def result
      user.contexts.find_by_sql([sql, user.id])
    end

    private

    def sql
      query = "SELECT c.id AS id, c.name AS name, count(c.id) AS total "
      query << "FROM contexts c, todos t "
      query << "WHERE t.context_id=c.id "
      query << "AND t.user_id = ? "
      if running
        query << "AND t.completed_at IS NULL "
        query << "AND NOT c.state='hidden' "
      end
      query << "GROUP BY c.id, c.name "
      query << "ORDER BY total DESC "
      if limit
        query << "LIMIT #{limit}"
      end
      query
    end
  end
end
