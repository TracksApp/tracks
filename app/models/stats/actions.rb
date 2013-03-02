module Stats
  class Actions

    SECONDS_PER_DAY = 86400;

    attr_reader :user
    def initialize(user)
      @user = user
    end

    def avg_ttc
      @avg_ttc ||= (sum/count)/SECONDS_PER_DAY
    end

    def max_ttc
      @max_ttc ||= max/SECONDS_PER_DAY
    end

    def min_ttc
      @min_ttc ||= min/SECONDS_PER_DAY
    end

    def min_ttc_sec
      min_ttc_sec = arbitrary_day + min # convert to a datetime
      @actions_min_ttc_sec = (min_ttc_sec).strftime("%H:%M:%S")
      @actions_min_ttc_sec = (min / SECONDS_PER_DAY).round.to_s + " days " + @actions_min_ttc_sec if min > SECONDS_PER_DAY
      @actions_min_ttc_sec
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

    def arbitrary_day
      @arbitrary_day ||= Time.utc(2000,1,1,0,0)
    end

    def one_year
      @one_year ||= 12.months.ago.beginning_of_day
    end

    def one_month
      @one_month ||= 1.month.ago.beginning_of_day
    end

    def completed
      @completed ||= user.todos.completed.select("completed_at, created_at")
    end

    def durations
      @durations ||= completed.map do |r|
        (r.completed_at - r.created_at)
      end
    end

    def sum
      @sum ||= durations.inject(0) {|sum, d| sum + d}
    end

    def min
      @min ||= durations.min || 0
    end

    def max
      @max ||= durations.max || 0
    end

    def count
      completed.empty? ? 1 : completed.size
    end

    def new_since(cutoff)
      user.todos.created_after(cutoff).count
    end

    def done_since(cutoff)
      user.todos.completed.completed_after(cutoff).count
    end

  end
end
