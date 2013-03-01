# tag cloud code inspired by this article
#  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
module Stats
  class TagCloud

    attr_reader :current_user,
      :tags_for_cloud, :tags_min, :tags_divisor,
      :tags_for_cloud_90days, :tags_min_90days, :tags_divisor_90days
    def initialize(current_user, cut_off_3months)
      @current_user = current_user
      @cut_off_3months = cut_off_3months
    end

    def compute
      levels=10
      # TODO: parameterize limit

      # Get the tag cloud for all tags for actions
      query = "SELECT tags.id, name, count(*) AS count"
      query << " FROM taggings, tags, todos"
      query << " WHERE tags.id = tag_id"
      query << " AND taggings.taggable_id = todos.id"
      query << " AND todos.user_id="+current_user.id.to_s+" "
      query << " AND taggings.taggable_type='Todo' "
      query << " GROUP BY tags.id, tags.name"
      query << " ORDER BY count DESC, name"
      query << " LIMIT 100"
      @tags_for_cloud = Tag.find_by_sql(query).sort_by { |tag| tag.name.downcase }

      max, @tags_min = 0, 0
      @tags_for_cloud.each { |t|
        max = [t.count.to_i, max].max
        @tags_min = [t.count.to_i, @tags_min].min
      }

      @tags_divisor = ((max - @tags_min) / levels) + 1

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
      @tags_for_cloud_90days = Tag.find_by_sql(
        [query, current_user.id, @cut_off_3months, @cut_off_3months]
      ).sort_by { |tag| tag.name.downcase }

      max_90days, @tags_min_90days = 0, 0
      @tags_for_cloud_90days.each { |t|
        max_90days = [t.count.to_i, max_90days].max
        @tags_min_90days = [t.count.to_i, @tags_min_90days].min
      }

      @tags_divisor_90days = ((max_90days - @tags_min_90days) / levels) + 1

    end

  end
end
