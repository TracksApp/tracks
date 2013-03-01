# tag cloud code inspired by this article
#  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
module Stats
  class TagCloud

    attr_reader :user, :cutoff, :levels,
      :tags, :min, :divisor
    def initialize(user, cutoff = nil)
      @user = user
      @cutoff = cutoff
      @levels = 10
    end

    def compute
      @tags = top_tags
      max, @min = 0, 0
      @tags.each { |t|
        max = [t.count.to_i, max].max
        @min = [t.count.to_i, @min].min
      }
      @divisor = ((max - @min) / levels) + 1
    end

    private

    def top_tags
      params = [sql, user.id]
      params += [cutoff, cutoff] if cutoff
      Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
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
