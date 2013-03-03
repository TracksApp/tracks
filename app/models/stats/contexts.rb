module Stats
  class Contexts

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def actions
      @actions ||= Stats::TopContextsQuery.new(user, :limit => 5).result
    end

    def running_actions
      @running_actions ||= Stats::TopContextsQuery.new(user, :limit => 5, :running => true).result
    end

    def charts
      @charts = %w{
        context_total_actions_data
        context_running_actions_data
      }.map do |action|
        Stats::Chart.new(action, :height => 325)
      end
    end

  end
end
