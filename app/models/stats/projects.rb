module Stats
  class Projects

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def runtime
      @runtime ||= find_top10_longest_running_projects
    end

    def actions
      @actions ||= Stats::TopProjectsQuery.new(user).result
    end

    def actions_last30days
      @actions_last30days ||= Stats::TopProjectsQuery.new(user, 1.month.ago.beginning_of_day).result
    end

    private

    def find_top10_longest_running_projects
      projects = user.projects.order('created_at ASC')
      projects.sort_by{ |p| p.running_time }.take(10)
    end

  end
end
