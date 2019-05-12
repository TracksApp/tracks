module Stats
  class Actions

    SECONDS_PER_DAY = 86400;

    attr_reader :user
    def initialize(user)
      @user = user

      @today = Time.zone.now.utc.beginning_of_day
      @cut_off_year = 12.months.ago.beginning_of_day
      @cut_off_year_plus3 = 15.months.ago.beginning_of_day
      @cut_off_month = 1.month.ago.beginning_of_day
      @cut_off_30days = 30.days.ago.beginning_of_day
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
      }.map do |action|
        Stats::Chart.new(action)
      end
    end

    def running_time_data
      @actions_running_time = @user.todos.not_completed.select("created_at").reorder("created_at DESC")
  
      # convert to array and fill in non-existing weeks with 0
      @max_weeks = difference_in_weeks(@today, @actions_running_time.last.created_at)
      @actions_running_per_week_array = convert_to_weeks_from_today_array(@actions_running_time, @max_weeks+1, :created_at)
  
      # cut off chart at 52 weeks = one year
      @count = [52, @max_weeks].min
  
      # convert to new array to hold max @cut_off elems + 1 for sum of actions after @cut_off
      @actions_running_time_array = cut_off_array_with_sum(@actions_running_per_week_array, @count)
      @max_actions = @actions_running_time_array.max
  
      # get percentage done cumulative
      @cum_percent_done = convert_to_cumulative_array(@actions_running_time_array, @actions_running_time.count )
    end

    def open_per_week_data
      @actions_started = @user.todos.created_after(@today-53.weeks).
        select("todos.created_at, todos.completed_at").
        reorder("todos.created_at DESC")
  
      @max_weeks = difference_in_weeks(@today, @actions_started.last.created_at)
  
      # cut off chart at 52 weeks = one year
      @count = [52, @max_weeks].min
  
      @actions_open_per_week_array = convert_to_weeks_running_from_today_array(@actions_started, @max_weeks+1)
      @actions_open_per_week_array = cut_off_array(@actions_open_per_week_array, @count)

      return @actions_open_per_week_array.each_with_index.map { |total, week| [week, total] }
    end

    def day_of_week_all_data
      @actions_creation_day = @user.todos.select("created_at")
      @actions_completion_day = @user.todos.completed.select("completed_at")
  
      # convert to array and fill in non-existing days
      @actions_creation_day_array = Array.new(7) { |i| 0}
      @actions_creation_day.each { |t| @actions_creation_day_array[ t.created_at.wday ] += 1 } 
      @max = @actions_creation_day_array.max
  
      # convert to array and fill in non-existing days
      @actions_completion_day_array = Array.new(7) { |i| 0}
      @actions_completion_day.each { |t| @actions_completion_day_array[ t.completed_at.wday ] += 1 } 
  
      # FIXME: Day of week as string instead of number
      return [
        {name: "Created", data: @actions_creation_day_array.each_with_index.map { |total, day| [day, total] } },
        {name: "Completed", data: @actions_completion_day_array.each_with_index.map { |total, day| [day, total] } }
      ]
    end

    def day_of_week_30days_data
      @actions_creation_day = @user.todos.created_after(@cut_off_month).select("created_at")
      @actions_completion_day = @user.todos.completed_after(@cut_off_month).select("completed_at")
  
      # convert to hash to be able to fill in non-existing days
      @max=0
      @actions_creation_day_array = Array.new(7) { |i| 0}
      @actions_creation_day.each { |r| @actions_creation_day_array[ r.created_at.wday ] += 1 }
  
      # convert to hash to be able to fill in non-existing days
      @actions_completion_day_array = Array.new(7) { |i| 0}
      @actions_completion_day.each { |r| @actions_completion_day_array[r.completed_at.wday] += 1 }
  
      # FIXME: Day of week as string instead of number
      return [
        {name: "Created", data: @actions_creation_day_array.each_with_index.map { |total, day| [day, total] } },
        {name: "Completed", data: @actions_completion_day_array.each_with_index.map { |total, day| [day, total] } }
      ]
    end

    def time_of_day_all_data
      @actions_creation_hour = @user.todos.select("created_at")
      @actions_completion_hour = @user.todos.completed.select("completed_at")
  
      # convert to hash to be able to fill in non-existing days
      @actions_creation_hour_array = Array.new(24) { |i| 0}
      @actions_creation_hour.each{|r| @actions_creation_hour_array[r.created_at.hour] += 1 } 
  
      # convert to hash to be able to fill in non-existing days
      @actions_completion_hour_array = Array.new(24) { |i| 0}
      @actions_completion_hour.each{|r| @actions_completion_hour_array[r.completed_at.hour] += 1 } 
  
      return [
        {name: "Created", data: @actions_creation_hour_array.each_with_index.map { |total, hour| [hour, total] } },
        {name: "Completed", data: @actions_completion_hour_array.each_with_index.map { |total, hour| [hour, total] } }
      ]
    end

    def time_of_day_30days_data
      @actions_creation_hour = @user.todos.created_after(@cut_off_month).select("created_at")
      @actions_completion_hour = @user.todos.completed_after(@cut_off_month).select("completed_at")
  
      # convert to hash to be able to fill in non-existing days
      @actions_creation_hour_array = Array.new(24) { |i| 0}
      @actions_creation_hour.each{|r| @actions_creation_hour_array[r.created_at.hour] += 1 } 
  
      # convert to hash to be able to fill in non-existing days
      @actions_completion_hour_array = Array.new(24) { |i| 0}
      @actions_completion_hour.each{|r| @actions_completion_hour_array[r.completed_at.hour] += 1 } 
  
      return [
        {name: "Created", data: @actions_creation_hour_array.each_with_index.map { |total, hour| [hour, total] } },
        {name: "Completed", data: @actions_completion_hour_array.each_with_index.map { |total, hour| [hour, total] } }
      ]
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

    # assumes date1 > date2
    def difference_in_days(date1, date2)
      return ((date1.utc.at_midnight-date2.utc.at_midnight)/SECONDS_PER_DAY).to_i
    end
  
    # assumes date1 > date2
    def difference_in_weeks(date1, date2)
      return difference_in_days(date1, date2) / 7
    end

    # uses the supplied block to determine array of indexes in hash
    # the block should return an array of indexes each is added to the hash and summed
    def convert_to_array(records, upper_bound)
      a = Array.new(upper_bound, 0)
      records.each { |r| (yield r).each { |i| a[i] += 1 if a[i] } }
      a
    end
  
    def convert_to_weeks_running_from_today_array(records, array_size)
      return convert_to_array(records, array_size) { |r| week_indexes_of(r) }
    end

    def cut_off_array(array, cut_off)
      return Array.new(cut_off){|i| array[i]||0}
    end

    def week_indexes_of(record)
      a = []
      start_week = difference_in_weeks(@today, record.created_at)
      end_week   = record.completed_at ? difference_in_weeks(@today, record.completed_at) : 0
      end_week.upto(start_week) { |i| a << i };
      return a
    end
  end
end
