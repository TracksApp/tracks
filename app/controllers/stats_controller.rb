class StatsController < ApplicationController

  SECONDS_PER_DAY = 86400;

  helper :todos, :projects, :recurring_todos
  append_before_filter :init, :except => :index

  def index
    @page_title = t('stats.index_title')
    @hidden_contexts = current_user.contexts.hidden
    @stats = Stats::UserStats.new(current_user)
  end

  def actions_done_last12months_data
    # get actions created and completed in the past 12+3 months. +3 for running
    # - outermost set of entries needed for these calculations
    actions_last12months = current_user.todos.created_or_completed_after(@cut_off_year_plus3).select("completed_at,created_at")

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
    @interpolated_actions_created_this_month = interpolate_avg_for_current_month(@actions_created_last12months_array)
    @interpolated_actions_done_this_month = interpolate_avg_for_current_month(@actions_done_last12months_array)

    @created_count_array = Array.new(13, actions_last12months.created_after(@cut_off_year).count(:all)/12.0)
    @done_count_array    = Array.new(13, actions_last12months.completed_after(@cut_off_year).count(:all)/12.0)
    render :layout => false
  end

  def interpolate_avg_for_current_month(set)
    (set[0]*(1/percent_of_month) + set[1] + set[2]) / 3.0
  end

  def percent_of_month
    Time.zone.now.day / Time.zone.now.end_of_month.day.to_f
  end

  def actions_done_last_years
    @page_title = t('stats.index_title')
    @chart = Stats::Chart.new('actions_done_lastyears_data', :height => 400, :width => 900)
  end

  def actions_done_lastyears_data
    actions_last_months = current_user.todos.select("completed_at,created_at")

    month_count = difference_in_months(@today, actions_last_months.minimum(:created_at))
    # because this action is not scoped by date, the minimum created_at should always be
    # less than the minimum completed_at, so no reason to check minimum completed_at

    # convert to array and fill in non-existing months
    @actions_done_last_months_array = put_events_into_month_buckets(actions_last_months, month_count+1, :completed_at)
    @actions_created_last_months_array = put_events_into_month_buckets(actions_last_months, month_count+1, :created_at)

    # find max for graph in both hashes
    @max = (@actions_done_last_months_array + @actions_created_last_months_array).max

    # set running avg
    @actions_done_avg_last_months_array = compute_running_avg_array(@actions_done_last_months_array,month_count+1)
    @actions_created_avg_last_months_array = compute_running_avg_array(@actions_created_last_months_array,month_count+1)

    # interpolate avg for this month.
    @interpolated_actions_created_this_month = interpolate_avg_for_current_month(@actions_created_last_months_array)
    @interpolated_actions_done_this_month = interpolate_avg_for_current_month(@actions_done_last_months_array)

    @created_count_array = Array.new(month_count+1, actions_last_months.select { |x| x.created_at }.size/month_count)
    @done_count_array    = Array.new(month_count+1, actions_last_months.select { |x| x.completed_at }.size/month_count)

    render :layout => false
  end

  def actions_done_last30days_data
    # get actions created and completed in the past 30 days.
    @actions_done_last30days = current_user.todos.completed_after(@cut_off_30days).select("completed_at")
    @actions_created_last30days = current_user.todos.created_after(@cut_off_30days).select("created_at")

    # convert to array. 30+1 to have 30 complete days and one current day [0]
    @actions_done_last30days_array = convert_to_days_from_today_array(@actions_done_last30days, 31, :completed_at)
    @actions_created_last30days_array = convert_to_days_from_today_array(@actions_created_last30days, 31, :created_at)

    # find max for graph in both hashes
    @max = [@actions_done_last30days_array.max, @actions_created_last30days_array.max].max

    render :layout => false
  end

  def actions_completion_time_data
    @actions_completion_time = current_user.todos.completed.select("completed_at, created_at").reorder("completed_at DESC" )

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

    render :layout => false
  end

  def actions_running_time_data
    @actions_running_time = current_user.todos.not_completed.select("created_at").reorder("created_at DESC")

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

    render :layout => false
  end

  def actions_visible_running_time_data
    # running means
    # - not completed (completed_at must be null)
    # visible means
    # - actions not part of a hidden project
    # - actions not part of a hidden context
    # - actions not deferred (show_from must be null)
    # - actions not pending/blocked

    @actions_running_time = current_user.todos.not_completed.not_hidden.not_deferred_or_blocked.
      select("todos.created_at").
      reorder("todos.created_at DESC")

    @max_weeks = difference_in_weeks(@today, @actions_running_time.last.created_at)
    @actions_running_per_week_array = convert_to_weeks_from_today_array(@actions_running_time, @max_weeks+1, :created_at)

    # cut off chart at 52 weeks = one year
    @count = [52, @max_weeks].min

    # convert to new array to hold max @cut_off elems + 1 for sum of actions after @cut_off
    @actions_running_time_array = cut_off_array_with_sum(@actions_running_per_week_array, @count)
    @max_actions = @actions_running_time_array.max

    # get percentage done cumulative
    @cum_percent_done = convert_to_cumulative_array(@actions_running_time_array, @actions_running_time.count )

    render :layout => false
  end

  def actions_open_per_week_data
    @actions_started = current_user.todos.created_after(@today-53.weeks).
      select("todos.created_at, todos.completed_at").
      reorder("todos.created_at DESC")

    @max_weeks = difference_in_weeks(@today, @actions_started.last.created_at)

    # cut off chart at 52 weeks = one year
    @count = [52, @max_weeks].min

    @actions_open_per_week_array = convert_to_weeks_running_from_today_array(@actions_started, @max_weeks+1)
    @actions_open_per_week_array = cut_off_array(@actions_open_per_week_array, @count)
    @max_actions = (@actions_open_per_week_array.max or 0)

    render :layout => false
  end

  def context_total_actions_data
    actions = Stats::TopContextsQuery.new(current_user).result

    @data = Stats::PieChartData.new(actions, t('stats.spread_of_actions_for_all_context'), 70)

    render :pie_chart_data, :layout => false
  end

  def context_running_actions_data
    actions = Stats::TopContextsQuery.new(current_user, :running => true).result
    @data = Stats::PieChartData.new(actions, t('stats.spread_of_running_actions_for_visible_contexts'), 60)

    render :pie_chart_data, :layout => false
  end

  def actions_day_of_week_all_data
    @actions_creation_day = current_user.todos.select("created_at")
    @actions_completion_day = current_user.todos.completed.select("completed_at")

    # convert to array and fill in non-existing days
    @actions_creation_day_array = Array.new(7) { |i| 0}
    @actions_creation_day.each { |t| @actions_creation_day_array[ t.created_at.wday ] += 1 }
    @max = @actions_creation_day_array.max

    # convert to array and fill in non-existing days
    @actions_completion_day_array = Array.new(7) { |i| 0}
    @actions_completion_day.each { |t| @actions_completion_day_array[ t.completed_at.wday ] += 1 }
    @max = @actions_completion_day_array.max

    render :layout => false
  end

  def actions_day_of_week_30days_data
    @actions_creation_day = current_user.todos.created_after(@cut_off_month).select("created_at")
    @actions_completion_day = current_user.todos.completed_after(@cut_off_month).select("completed_at")

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_day_array = Array.new(7) { |i| 0}
    @actions_creation_day.each { |r| @actions_creation_day_array[ r.created_at.wday ] += 1 }

    # convert to hash to be able to fill in non-existing days
    @actions_completion_day_array = Array.new(7) { |i| 0}
    @actions_completion_day.each { |r| @actions_completion_day_array[r.completed_at.wday] += 1 }

    @max = [@actions_creation_day_array.max, @actions_completion_day_array.max].max

    render :layout => false
  end

  def actions_time_of_day_all_data
    @actions_creation_hour = current_user.todos.select("created_at")
    @actions_completion_hour = current_user.todos.completed.select("completed_at")

    # convert to hash to be able to fill in non-existing days
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each{|r| @actions_creation_hour_array[r.created_at.hour] += 1 }

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each{|r| @actions_completion_hour_array[r.completed_at.hour] += 1 }

    @max = [@actions_creation_hour_array.max, @actions_completion_hour_array.max].max

    render :layout => false
  end

  def actions_time_of_day_30days_data
    @actions_creation_hour = current_user.todos.created_after(@cut_off_month).select("created_at")
    @actions_completion_hour = current_user.todos.completed_after(@cut_off_month).select("completed_at")

    # convert to hash to be able to fill in non-existing days
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each{|r| @actions_creation_hour_array[r.created_at.hour] += 1 }

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each{|r| @actions_completion_hour_array[r.completed_at.hour] += 1 }

    @max = [@actions_creation_hour_array.max, @max = @actions_completion_hour_array.max].max

    render :layout => false
  end

  def show_selected_actions_from_chart
    @page_title = t('stats.action_selection_title')
    @count = 99

    @source_view = 'stats'

    case params['id']
    when 'avrt', 'avrt_end' # actions_visible_running_time

      # HACK: because open flash chart uses & to denote the end of a parameter,
      # we cannot use URLs with multiple parameters (that would use &). So we
      # revert to using two id's for the same selection. avtr_end means that the
      # last bar of the chart is selected. avtr is used for all other bars

      week_from = params['index'].to_i
      week_to = week_from+1

      @chart = Stats::Chart.new('actions_visible_running_time_data')
      @page_title = t('stats.actions_selected_from_week')
      @further = false
      if params['id'] == 'avrt_end'
        @page_title += week_from.to_s + t('stats.actions_further')
        @further = true
      else
        @page_title += week_from.to_s + " - " + week_to.to_s + ""
      end

      # get all running actions that are visible
      @actions_running_time = current_user.todos.not_completed.not_hidden.not_deferred_or_blocked.
        select("todos.id, todos.created_at").
        reorder("todos.created_at DESC")

      selected_todo_ids = get_ids_from(@actions_running_time, week_from, week_to, params['id']== 'avrt_end')
      @selected_actions = selected_todo_ids.size == 0 ? [] : current_user.todos.where("id in (" + selected_todo_ids.join(",") + ")")
      @count = @selected_actions.size

      render :action => "show_selection_from_chart"

    when 'art', 'art_end'
      week_from = params['index'].to_i
      week_to = week_from+1

      @chart = Stats::Chart.new('actions_running_time_data')
      @page_title = "Actions selected from week "
      @further = false
      if params['id'] == 'art_end'
        @page_title += week_from.to_s + " and further"
        @further = true
      else
        @page_title += week_from.to_s + " - " + week_to.to_s + ""
      end

      # get all running actions
      @actions_running_time = current_user.todos.not_completed.select("id, created_at")

      selected_todo_ids = get_ids_from(@actions_running_time, week_from, week_to, params['id']=='art_end')
      @selected_actions = selected_todo_ids.size == 0 ? [] : current_user.todos.where("id in (#{selected_todo_ids.join(",")})")
      @count = @selected_actions.size

      render :action => "show_selection_from_chart"
    else
      # render error
      render_failure "404 NOT FOUND. Unknown query selected"
    end
  end

  def done
    @source_view = 'done'

    init_not_done_counts

    @done_recently = current_user.todos.completed.limit(10).reorder('completed_at DESC').includes(Todo::DEFAULT_INCLUDES)
    @last_completed_projects = current_user.projects.completed.limit(10).reorder('completed_at DESC').includes(:todos, :notes)
    @last_completed_contexts = []
    @last_completed_recurring_todos = current_user.recurring_todos.completed.limit(10).reorder('completed_at DESC').includes(:tags, :taggings)
    #TODO: @last_completed_contexts = current_user.contexts.completed.all(:limit => 10, :order => 'completed_at DESC')
  end

  private

  def init
    @me = self # for meta programming

    # get the current date wih time set to 0:0
    @today = Time.zone.now.utc.beginning_of_day

    # define cut_off date and discard the time for a month, 3 months and a year
    @cut_off_year = 12.months.ago.beginning_of_day
    @cut_off_year_plus3 = 15.months.ago.beginning_of_day
    @cut_off_month = 1.month.ago.beginning_of_day
    @cut_off_30days = 30.days.ago.beginning_of_day
  end

  def get_ids_from (actions, week_from, week_to, at_end)
    selected_todo_ids = []

    actions.each do |r|
      weeks = difference_in_weeks(@today, r.created_at)
      if at_end
        selected_todo_ids << r.id.to_s if weeks >= week_from
      else
        selected_todo_ids << r.id.to_s if weeks.between?(week_from, week_to-1)
      end
    end

    return selected_todo_ids
  end

  # uses the supplied block to determine array of indexes in hash
  # the block should return an array of indexes each is added to the hash and summed
  def convert_to_array(records, upper_bound)
    a = Array.new(upper_bound, 0)
    records.each { |r| (yield r).each { |i| a[i] += 1 if a[i] } }
    a
  end

  def put_events_into_month_buckets(records, array_size, date_method_on_todo)
    convert_to_array(records.select { |x| x.send(date_method_on_todo) }, array_size) { |r| [difference_in_months(@today, r.send(date_method_on_todo))]}
  end

  def convert_to_days_from_today_array(records, array_size, date_method_on_todo)
    return convert_to_array(records, array_size){ |r| [difference_in_days(@today, r.send(date_method_on_todo))]}
  end

  def convert_to_weeks_from_today_array(records, array_size, date_method_on_todo)
    return convert_to_array(records, array_size) { |r| [difference_in_weeks(@today, r.send(date_method_on_todo))]}
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
    end_week.upto(start_week) { |i| a << i };
    return a
  end

  # returns a new array containing all elems of array up to cut_off and
  # adds the sum of the rest of array to the last elem
  def cut_off_array_with_sum(array, cut_off)
    # +1 to hold sum of rest
    a = Array.new(cut_off+1){|i| array[i]||0}
    # add rest of array to last elem
    a[cut_off] += array.inject(:+) - a.inject(:+)
    return a
  end

  def cut_off_array(array, cut_off)
    return Array.new(cut_off){|i| array[i]||0}
  end

  def convert_to_cumulative_array(array, max)
    # calculate fractions
    a = Array.new(array.size){|i| array[i]*100.0/max}
    # make cumulative
    1.upto(array.size-1){ |i| a[i] += a[i-1] }
    return a
  end

  # assumes date1 > date2
  # this results in the number of months before the month of date1, not taking days into account, so diff of 31-dec and 1-jan is 1 month!
  def difference_in_months(date1, date2)
    return (date1.utc.year - date2.utc.year)*12 + (date1.utc.month - date2.utc.month)
  end

  # assumes date1 > date2
  def difference_in_days(date1, date2)
    return ((date1.utc.at_midnight-date2.utc.at_midnight)/SECONDS_PER_DAY).to_i
  end

  # assumes date1 > date2
  def difference_in_weeks(date1, date2)
    return difference_in_days(date1, date2) / 7
  end

  def three_month_avg(set, i)
    (set.fetch(i){ 0 } + set.fetch(i+1){ 0 } + set.fetch(i+2){ 0 }) / 3.0
  end

  def set_three_month_avg(set,upper_bound)
    (0..upper_bound-1).map { |i| three_month_avg(set, i) }
  end

  # sets "null" on first column and - if necessary - cleans up last two columns, which may have insufficient data
  def compute_running_avg_array(set, upper_bound)
    result = set_three_month_avg(set, upper_bound)
    result[upper_bound-1] = result[upper_bound-1] * 3 if upper_bound == set.length
    result[upper_bound-2] = result[upper_bound-2] * 3 / 2 if upper_bound > 1 and upper_bound == set.length
    result[0] = "null"
    result
  end # unsolved, not triggered, edge case for set.length == upper_bound + 1

end
