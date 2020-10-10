class StatsController < ApplicationController
  SECONDS_PER_DAY = 86_400;

  helper :todos, :projects, :recurring_todos
  append_before_action :init, :except => :index

  def index
    @page_title = t('stats.index_title')
    @hidden_contexts = current_user.contexts.hidden
    @stats = Stats::UserStats.new(current_user)
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
    @actions_done_avg_last_months_array = compute_running_avg_array(@actions_done_last_months_array,month_count + 1)
    @actions_created_avg_last_months_array = compute_running_avg_array(@actions_created_last_months_array,month_count + 1)

    # interpolate avg for this month.
    @interpolated_actions_created_this_month = interpolate_avg_for_current_month(@actions_created_last_months_array)
    @interpolated_actions_done_this_month = interpolate_avg_for_current_month(@actions_done_last_months_array)

    @created_count_array = Array.new(month_count + 1, actions_last_months.select { |x| x.created_at }.size / month_count)
    @done_count_array    = Array.new(month_count + 1, actions_last_months.select { |x| x.completed_at }.size / month_count)

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
      @actions_running_time = current_user.todos.not_completed.not_hidden.not_deferred_or_blocked
        .select("todos.id, todos.created_at")
        .reorder("todos.created_at DESC")

      selected_todo_ids = get_ids_from(@actions_running_time, week_from, week_to, params['id'] == 'avrt_end')
      @selected_actions = selected_todo_ids.size == 0 ? [] : current_user.todos.where("id in (" + selected_todo_ids.join(",") + ")")
      @count = @selected_actions.size

      render :action => "show_selection_from_chart"

    when 'art', 'art_end'
      week_from = params['index'].to_i
      week_to = week_from + 1

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

      selected_todo_ids = get_ids_from(@actions_running_time, week_from, week_to, params['id'] == 'art_end')
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
        selected_todo_ids << r.id.to_s if weeks.between?(week_from, week_to - 1)
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
    convert_to_array(records.select { |x| x.send(date_method_on_todo) }, array_size) { |r| [difference_in_months(@today, r.send(date_method_on_todo))] }
  end

  # assumes date1 > date2
  def difference_in_days(date1, date2)
    return ((date1.utc.at_midnight - date2.utc.at_midnight) / SECONDS_PER_DAY).to_i
  end

  # assumes date1 > date2
  def difference_in_weeks(date1, date2)
    return difference_in_days(date1, date2) / 7
  end
end
