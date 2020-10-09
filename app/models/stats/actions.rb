module Stats
  class Actions
    SECONDS_PER_DAY = 86_400

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

    def done_last12months_data
      # get actions created and completed in the past 12+3 months. +3 for running
      # - outermost set of entries needed for these calculations
      actions_last12months = @user.todos.created_or_completed_after(@cut_off_year_plus3).select("completed_at,created_at")

      # convert to array and fill in non-existing months
      @actions_done_last12months_array = put_events_into_month_buckets(actions_last12months, 13, :completed_at)
      @actions_created_last12months_array = put_events_into_month_buckets(actions_last12months, 13, :created_at)

      # find max for graph in both arrays
      @max = (@actions_done_last12months_array + @actions_created_last12months_array).max

      # find running avg
      done_in_last_15_months = put_events_into_month_buckets(actions_last12months, 16, :completed_at)
      created_in_last_15_months = put_events_into_month_buckets(actions_last12months, 16, :created_at)

      @actions_done_avg_last12months_array = compute_running_avg_array(done_in_last_15_months, 13)
      @actions_created_avg_last12months_array = compute_running_avg_array(created_in_last_15_months, 13)

      # interpolate avg for current month.
      # FIXME: These should also be used.
      @interpolated_actions_created_this_month = interpolate_avg_for_current_month(@actions_created_last12months_array)
      @interpolated_actions_done_this_month = interpolate_avg_for_current_month(@actions_done_last12months_array)

      @created_count_array = Array.new(13, actions_last12months.created_after(@cut_off_year).count(:all) / 12.0)
      @done_count_array    = Array.new(13, actions_last12months.completed_after(@cut_off_year).count(:all) / 12.0)

      return {
        datasets: [
          { label: I18n.t('stats.labels.avg_created'), data: @created_count_array, type: "line" },
          { label: I18n.t('stats.labels.avg_completed'), data: @done_count_array, type: "line" },
          { label: I18n.t('stats.labels.month_avg_completed', :months => 3), data: @actions_done_avg_last12months_array, type: "line" },
          { label: I18n.t('stats.labels.month_avg_created', :months => 3), data: @actions_created_avg_last12months_array, type: "line" },
          { label: I18n.t('stats.labels.created'), data: @actions_created_last12months_array },
          { label: I18n.t('stats.labels.completed'), data: @actions_done_last12months_array },
        ],
        labels: array_of_month_labels(@done_count_array.size),
      }
    end

    def done_last30days_data
      # get actions created and completed in the past 30 days.
      @actions_done_last30days = @user.todos.completed_after(@cut_off_30days).select("completed_at")
      @actions_created_last30days = @user.todos.created_after(@cut_off_30days).select("created_at")

      # convert to array. 30+1 to have 30 complete days and one current day [0]
      @actions_done_last30days_array = convert_to_days_from_today_array(@actions_done_last30days, 31, :completed_at)
      @actions_created_last30days_array = convert_to_days_from_today_array(@actions_created_last30days, 31, :created_at)

      # find max for graph in both hashes
      @max = [@actions_done_last30days_array.max, @actions_created_last30days_array.max].max

      created_count_array = Array.new(30) { |i| @actions_created_last30days.size / 30.0 }
      done_count_array    = Array.new(30) { |i| @actions_done_last30days.size / 30.0 }
      # TODO: make the strftime i18n proof
      time_labels         = Array.new(30) { |i| I18n.l(Time.zone.now-i.days, :format => :stats)  }

      return {
        datasets: [
          { label: I18n.t('stats.labels.avg_created'), data: created_count_array, type: "line" },
          { label: I18n.t('stats.labels.avg_completed'), data: done_count_array, type: "line" },
          { label: I18n.t('stats.labels.created'), data: @actions_created_last30days_array },
          { label: I18n.t('stats.labels.completed'), data: @actions_done_last30days_array },
        ],
        labels: time_labels,
      }
    end

    def completion_time_data
      @actions_completion_time = @user.todos.completed.select("completed_at, created_at").reorder("completed_at DESC" )

      # convert to array and fill in non-existing weeks with 0
      @max_weeks = @actions_completion_time.last ? difference_in_weeks(@today, @actions_completion_time.last.completed_at) : 1
      @actions_completed_per_week_array = convert_to_weeks_running_array(@actions_completion_time, @max_weeks+1)

      # stop the chart after 10 weeks
      @count = [10, @max_weeks].min

      # convert to new array to hold max @cut_off elems + 1 for sum of actions after @cut_off
      @actions_completion_time_array = cut_off_array_with_sum(@actions_completed_per_week_array, @count)
      @max_actions = @actions_completion_time_array.max

      # get percentage done cumulative
      @cum_percent_done = convert_to_cumulative_array(@actions_completion_time_array, @actions_completion_time.count(:all))

      time_labels         = Array.new(@count) { |i| "#{i}-#{i+1}" }
      time_labels[0]      = I18n.t('stats.within_one')
      time_labels[@count] = "> #{@count}"

      return {
        datasets: [
          { label: I18n.t('stats.legend.percentage'), data: @cum_percent_done, type: "line" },
          { label: I18n.t('stats.legend.actions'), data: @actions_completion_time_array },
        ],
        labels: time_labels,
      }
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

      time_labels = Array.new(@count) { |i| "#{i}-#{i+1}" }
      time_labels[0] = "< 1"
      time_labels[@count] = "> #{@count}"

      return {
        datasets: [
          { label: I18n.t('stats.running_time_all_legend.percentage'), data: @cum_percent_done, type: "line" },
          { label: I18n.t('stats.running_time_all_legend.actions'), data: @actions_running_time_array },
        ],
        labels: time_labels,
      }
    end

    def visible_running_time_data
      # running means
      # - not completed (completed_at must be null)
      # visible means
      # - actions not part of a hidden project
      # - actions not part of a hidden context
      # - actions not deferred (show_from must be null)
      # - actions not pending/blocked

      @actions_running_time = @user.todos.not_completed.not_hidden.not_deferred_or_blocked
        .select("todos.created_at")
        .reorder("todos.created_at DESC")

      @max_weeks = difference_in_weeks(@today, @actions_running_time.last.created_at)
      @actions_running_per_week_array = convert_to_weeks_from_today_array(@actions_running_time, @max_weeks + 1, :created_at)

      # cut off chart at 52 weeks = one year
      @count = [52, @max_weeks].min

      # convert to new array to hold max @cut_off elems + 1 for sum of actions after @cut_off
      @actions_running_time_array = cut_off_array_with_sum(@actions_running_per_week_array, @count)
      @max_actions = @actions_running_time_array.max

      # get percentage done cumulative
      @cum_percent_done = convert_to_cumulative_array(@actions_running_time_array, @actions_running_time.count )

      time_labels = Array.new(@count) { |i| "#{i}-#{i+1}" }
      time_labels[0] = "< 1"
      time_labels[@count] = "> #{@count}"

      return {
        datasets: [
          { label: I18n.t('stats.running_time_legend.percentage'), data: @cum_percent_done, type: "line" },
          { label: I18n.t('stats.running_time_legend.actions'), data: @actions_running_time_array },
        ],
        labels: time_labels,
      }
    end

    def open_per_week_data
      @actions_started = @user.todos.created_after(@today - 53.weeks)
        .select("todos.created_at, todos.completed_at")
        .reorder("todos.created_at DESC")

      @max_weeks = difference_in_weeks(@today, @actions_started.last.created_at)

      # cut off chart at 52 weeks = one year
      @count = [52, @max_weeks].min

      @actions_open_per_week_array = convert_to_weeks_running_from_today_array(@actions_started, @max_weeks+1)
      @actions_open_per_week_array = cut_off_array(@actions_open_per_week_array, @count)

      time_labels = Array.new(@count+1) { |i| "#{i}-#{i+1}" }
      time_labels[0] = "< 1"

      return {
        datasets: [
          { label: I18n.t('stats.open_per_week_legend.actions'), data: @actions_open_per_week_array },
        ],
        labels: time_labels,
      }
    end

    def day_of_week_all_data
      @actions_creation_day = @user.todos.select("created_at")
      @actions_completion_day = @user.todos.completed.select("completed_at")

      # convert to array and fill in non-existing days
      @actions_creation_day_array = Array.new(7) { |i| 0 }
      @actions_creation_day.each { |t| @actions_creation_day_array[t.created_at.wday] += 1 }
      @max = @actions_creation_day_array.max

      # convert to array and fill in non-existing days
      @actions_completion_day_array = Array.new(7) { |i| 0 }
      @actions_completion_day.each { |t| @actions_completion_day_array[t.completed_at.wday] += 1 }

      return {
        datasets: [
          { label: I18n.t('stats.labels.created'), data: @actions_creation_day_array },
          { label: I18n.t('stats.labels.completed'), data: @actions_completion_day_array },
        ],
        labels: I18n.t('date.day_names'),
      }
    end

    def day_of_week_30days_data
      @actions_creation_day = @user.todos.created_after(@cut_off_month).select("created_at")
      @actions_completion_day = @user.todos.completed_after(@cut_off_month).select("completed_at")

      # convert to hash to be able to fill in non-existing days
      @max=0
      @actions_creation_day_array = Array.new(7) { |i| 0 }
      @actions_creation_day.each { |r| @actions_creation_day_array[r.created_at.wday] += 1 }

      # convert to hash to be able to fill in non-existing days
      @actions_completion_day_array = Array.new(7) { |i| 0 }
      @actions_completion_day.each { |r| @actions_completion_day_array[r.completed_at.wday] += 1 }

      return {
        datasets: [
          { label: I18n.t('stats.labels.created'), data: @actions_creation_day_array },
          { label: I18n.t('stats.labels.completed'), data: @actions_completion_day_array },
        ],
        labels: I18n.t('date.day_names'),
      }
    end

    def time_of_day_all_data
      @actions_creation_hour = @user.todos.select("created_at")
      @actions_completion_hour = @user.todos.completed.select("completed_at")

      # convert to hash to be able to fill in non-existing days
      @actions_creation_hour_array = Array.new(24) { |i| 0 }
      @actions_creation_hour.each{|r| @actions_creation_hour_array[r.created_at.hour] += 1 }

      # convert to hash to be able to fill in non-existing days
      @actions_completion_hour_array = Array.new(24) { |i| 0 }
      @actions_completion_hour.each{|r| @actions_completion_hour_array[r.completed_at.hour] += 1 }

      return {
        datasets: [
          { label: I18n.t('stats.labels.created'), data: @actions_creation_hour_array },
          { label: I18n.t('stats.labels.completed'), data: @actions_completion_hour_array },
        ],
        labels: @actions_creation_hour_array.each_with_index.map { |total, hour| [hour] },
      }
    end

    def time_of_day_30days_data
      @actions_creation_hour = @user.todos.created_after(@cut_off_month).select("created_at")
      @actions_completion_hour = @user.todos.completed_after(@cut_off_month).select("completed_at")

      # convert to hash to be able to fill in non-existing days
      @actions_creation_hour_array = Array.new(24) { |i| 0 }
      @actions_creation_hour.each{|r| @actions_creation_hour_array[r.created_at.hour] += 1 }

      # convert to hash to be able to fill in non-existing days
      @actions_completion_hour_array = Array.new(24) { |i| 0 }
      @actions_completion_hour.each{|r| @actions_completion_hour_array[r.completed_at.hour] += 1 }

      return {
        datasets: [
          { label: I18n.t('stats.labels.created'), data: @actions_creation_hour_array },
          { label: I18n.t('stats.labels.completed'), data: @actions_completion_hour_array },
        ],
        labels: @actions_creation_hour_array.each_with_index.map { |total, hour| [hour] },
      }
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

    def interpolate_avg_for_current_month(set)
      (set[0] * (1 / percent_of_month) + set[1] + set[2]) / 3.0
    end

    def percent_of_month
      Time.zone.now.day / Time.zone.now.end_of_month.day.to_f
    end

    # uses the supplied block to determine array of indexes in hash
    # the block should return an array of indexes each is added to the hash and summed
    def convert_to_array(records, upper_bound)
      a = Array.new(upper_bound, 0)
      records.each { |r| (yield r).each { |i| a[i] += 1 if a[i] } }
      a
    end

    def put_events_into_month_buckets(records, array_size, date_method_on_todo)
      convert_to_array(records.select { |x| x.send(date_method_on_todo) }, array_size) { |r| [difference_in_months(@today, r.send(date_method_on_todo))] }
    end

    def convert_to_days_from_today_array(records, array_size, date_method_on_todo)
      return convert_to_array(records, array_size) { |r| [difference_in_days(@today, r.send(date_method_on_todo))] }
    end

    def convert_to_weeks_from_today_array(records, array_size, date_method_on_todo)
      return convert_to_array(records, array_size) { |r| [difference_in_weeks(@today, r.send(date_method_on_todo))] }
    end

    def convert_to_weeks_running_array(records, array_size)
      return convert_to_array(records, array_size) { |r| [difference_in_weeks(r.completed_at, r.created_at)]}
    end

    def convert_to_weeks_running_from_today_array(records, array_size)
      return convert_to_array(records, array_size) { |r| week_indexes_of(r) }
    end

    def week_indexes_of(record)
      a = []
      start_week = difference_in_weeks(@today, record.created_at)
      end_week   = record.completed_at ? difference_in_weeks(@today, record.completed_at) : 0
      end_week.upto(start_week) { |i| a << i }
      return a
    end

    def cut_off_array_with_sum(array, cut_off)
      # +1 to hold sum of rest
      a = Array.new(cut_off + 1) { |i| array[i] || 0 }
      # add rest of array to last elem
      a[cut_off] += array.inject(:+) - a.inject(:+)
      return a
    end

    def cut_off_array(array, cut_off)
      return Array.new(cut_off) { |i| array[i] || 0 }
    end

    def convert_to_cumulative_array(array, max)
      # calculate fractions
      a = Array.new(array.size) {|i| array[i] * 100.0 / max}
      # make cumulative
      1.upto(array.size-1) { |i| a[i] += a[i - 1] }
      return a
    end

    def difference_in_months(date1, date2)
      return (date1.utc.year - date2.utc.year) * 12 + (date1.utc.month - date2.utc.month)
    end

    # assumes date1 > date2
    def difference_in_days(date1, date2)
      return ((date1.utc.at_midnight - date2.utc.at_midnight) / SECONDS_PER_DAY).to_i
    end

    # assumes date1 > date2
    def difference_in_weeks(date1, date2)
      return difference_in_days(date1, date2) / 7
    end

    def three_month_avg(set, i)
      (set.fetch(i) { 0 } + set.fetch(i+1) { 0 } + set.fetch(i + 2) { 0 }) / 3.0
    end

    def set_three_month_avg(set, upper_bound)
      (0..upper_bound - 1).map { |i| three_month_avg(set, i) }
    end

    def compute_running_avg_array(set, upper_bound)
      result = set_three_month_avg(set, upper_bound)
      result[upper_bound - 1] = result[upper_bound-1] * 3 if upper_bound == set.length
      result[upper_bound - 2] = result[upper_bound-2] * 3 / 2 if upper_bound > 1 and upper_bound == set.length
      result[0] = "null"
      result
    end # unsolved, not triggered, edge case for set.length == upper_bound + 1

    def month_label(i)
      I18n.t('date.month_names')[(Time.zone.now.mon - i -1 ) % 12 + 1]
    end

    def array_of_month_labels(count)
      Array.new(count) { |i| month_label(i) }
    end
  end
end
