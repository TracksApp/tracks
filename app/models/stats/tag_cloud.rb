# tag cloud code inspired by this article
#  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
module Stats
  class TagCloud

    attr_reader :user, :cutoff,
      :tags, :min, :divisor,
      :tags_90days, :min_90days, :divisor_90days
    def initialize(user, cutoff)
      @user = user
      @cutoff = cutoff
    end

    def compute
      levels=10
      # TODO: parameterize limit

      # Get the tag cloud for all tags for actions
      query = "SELECT tags.id, name, count(*) AS count"
      query << " FROM taggings, tags, todos"
      query << " WHERE tags.id = tag_id"
      query << " AND taggings.taggable_id = todos.id"
      query << " AND todos.user_id="+user.id.to_s+" "
      query << " AND taggings.taggable_type='Todo' "
      query << " GROUP BY tags.id, tags.name"
      query << " ORDER BY count DESC, name"
      query << " LIMIT 100"
      @tags = Tag.find_by_sql(query).sort_by { |tag| tag.name.downcase }

      max, @min = 0, 0
      @tags.each { |t|
        max = [t.count.to_i, max].max
        @min = [t.count.to_i, @min].min
      }

      @divisor = ((max - @min) / levels) + 1

      # Get the tag cloud for all tags for actions
      query = "SELECT tags.id, tags.name AS name, count(*) AS count"
      query << " FROM taggings, tags, todos"
      query << " WHERE tags.id = tag_id"
      query << " AND todos.user_id=? "
      query << " AND taggings.taggable_type='Todo' "
      query << " AND taggings.taggable_id=todos.id "
      query << " AND (todos.created_at > ? OR "
      query << "      todos.completed_at > ?) "
      query << " GROUP BY tags.id, tags.name"
      query << " ORDER BY count DESC, name"
      query << " LIMIT 100"
      @tags_90days = Tag.find_by_sql(
        [query, user.id, cutoff, cutoff]
      ).sort_by { |tag| tag.name.downcase }

      max_90days, @min_90days = 0, 0
      @tags_90days.each { |t|
        max_90days = [t.count.to_i, max_90days].max
        @min_90days = [t.count.to_i, @min_90days].min
      }

      @divisor_90days = ((max_90days - @min_90days) / levels) + 1

    end

  end
end
