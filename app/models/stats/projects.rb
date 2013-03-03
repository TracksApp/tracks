module Stats
  class Projects

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def runtime
      @runtime ||= user.projects.active.order('created_at ASC').limit(10)
    end

    def actions
      @actions ||= Stats::TopProjectsQuery.new(user).result
    end

    def actions_last30days
      @actions_last30days ||= Stats::TopProjectsQuery.new(user, 1.month.ago.beginning_of_day).result
    end

  end
end
