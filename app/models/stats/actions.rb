module Stats
  class Actions

    SECONDS_PER_DAY = 86400;

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def ttc
      @ttc ||= TimeToComplete.new(completed)
    end

    def done_last30days
      @done_last30days ||= done_since(one_month)
    end

    def done_last12months
      @done_last12months ||= done_since(one_year)
    end

    def created_last30days
      @sum_actions_created_last30days ||= new_since(one_month)
    end

    def created_last12months
      @sum_actions_created_last12months ||= new_since(one_year)
    end

    def completion_charts
      @completion_charts ||= %w{
     actions_done_last30days_data
     actions_done_last12months_data
     actions_completion_time_data
      }.map do |action|
        Stats::Chart.new(action)
      end
    end

    def timing_charts
      @timing_charts ||= %w{
      actions_visible_running_time_data
      actions_running_time_data
      actions_open_per_week_data
      actions_day_of_week_all_data
      actions_day_of_week_30days_data
      actions_time_of_day_all_data
      actions_time_of_day_30days_data
      }.map do |action|
        Stats::Chart.new(action)
      end
    end

    private

    def one_year
      @one_year ||= 12.months.ago.beginning_of_day
    end

    def one_month
      @one_month ||= 1.month.ago.beginning_of_day
    end

    def new_since(cutoff)
      user.todos.created_after(cutoff).count
    end

    def done_since(cutoff)
      user.todos.completed.completed_after(cutoff).count
    end

    def completed
      @completed ||= user.todos.completed.select("completed_at, created_at")
    end
  end
end
