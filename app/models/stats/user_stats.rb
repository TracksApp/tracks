module Stats
  class UserStats

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def actions
      @actions ||= Stats::Actions.new(user)
    end

    def totals
      @totals ||= Stats::Totals.new(user)
    end

    def projects
      @projects ||= Stats::Projects.new(user)
    end

    def contexts
      @contexts ||= Stats::Contexts.new(user)
    end

    def tag_cloud
      unless @tag_cloud
        tags = Stats::TagCloudQuery.new(user).result
        @tag_cloud = Stats::TagCloud.new(tags)
      end
      @tag_cloud
    end

    def tag_cloud_90days
      unless @tag_cloud_90days
        cutoff = 3.months.ago.beginning_of_day
        tags = Stats::TagCloudQuery.new(user, cutoff).result
        @tag_cloud_90days = Stats::TagCloud.new(tags)
      end
      @tag_cloud_90days
    end

  end
end
