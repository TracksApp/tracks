class StatsController < ApplicationController

  helper :todos, :projects, :recurring_todos

  append_before_filter :init, :exclude => []

  def index
    @page_title = t('stats.index_title')

    @tags_count = get_total_number_of_tags_of_user
    @unique_tags_count = get_unique_tags_of_user.size
    @hidden_contexts = current_user.contexts.hidden
    @first_action = current_user.todos.find(:first, :order => "created_at ASC")

    get_stats_actions
    get_stats_contexts
    get_stats_projects
    get_stats_tags

    render :layout => 'standard'
  end

  def actions_done_last12months_data
    # get actions created and completed in the past 12+3 months. +3 for running
    #   average
    @actions_done_last12months = current_user.todos.completed_after(@cut_off_year).find(:all, { :select => "completed_at" })
    @actions_created_last12months = current_user.todos.created_after(@cut_off_year).find(:all, { :select => "created_at"})
    @actions_done_last12monthsPlus3 = current_user.todos.completed_after(@cut_off_year_plus3).find(:all, { :select => "completed_at" })
    @actions_created_last12monthsPlus3 = current_user.todos.created_after(@cut_off_year_plus3).find(:all, { :select => "created_at"})

    # convert to array and fill in non-existing months
    @actions_done_last12months_array = convert_to_array(convert_to_hash(@actions_done_last12months, :difference_in_months, :completed_at),13)
    @actions_created_last12months_array = convert_to_array(convert_to_hash(@actions_created_last12months, :difference_in_months, :created_at),13)
    @actions_done_last12monthsPlus3_array = convert_to_array(convert_to_hash(@actions_done_last12monthsPlus3, :difference_in_months, :completed_at),15)
    @actions_created_last12monthsPlus3_array = convert_to_array(convert_to_hash(@actions_created_last12monthsPlus3, :difference_in_months, :created_at),15)
    
    # find max for graph in both arrays
    @max = [@actions_done_last12months_array.max, @actions_created_last12months_array.max].max

    # find running avg
    @actions_done_avg_last12months_array, @actions_created_avg_last12months_array =
      find_running_avg_array(@actions_done_last12monthsPlus3_array, @actions_created_last12monthsPlus3_array, 13)

    # interpolate avg for current month.
    percent_of_month = Time.zone.now.day.to_f / Time.zone.now.end_of_month.day.to_f
    @interpolated_actions_created_this_month = interpolate_avg(@actions_created_last12months_array, percent_of_month)
    @interpolated_actions_done_this_month = interpolate_avg(@actions_done_last12months_array, percent_of_month)

    render :layout => false
  end

  def actions_done_last_years
    @page_title = t('stats.index_title')
    @chart_width = 900
    @chart_height = 400
  end

  def actions_done_lastyears_data
    @actions_done_last_months = current_user.todos.completed.find(:all, { :select => "completed_at", :order => "completed_at DESC" })
    @actions_created_last_months = current_user.todos.find(:all, { :select => "created_at", :order => "created_at DESC" })

    # query is sorted, so use last todo to calculate number of months
    @month_count = [difference_in_months(@today, @actions_created_last_months.last.created_at),
      difference_in_months(@today, @actions_done_last_months.last.completed_at)].max

    # convert to array and fill in non-existing months
    @actions_done_last_months_array = convert_to_array(convert_to_hash(@actions_done_last_months, :difference_in_months, :completed_at), @month_count+1)
    @actions_created_last_months_array = convert_to_array(convert_to_hash(@actions_created_last_months, :difference_in_months, :created_at), @month_count+1)

    # find max for graph in both hashes
    @max = [@actions_done_last_months_array.max, @actions_created_last_months_array.max].max

    # find running avg
    @actions_done_avg_last_months_array, @actions_created_avg_last_months_array =
      find_running_avg_array(@actions_done_last_months_array, @actions_created_last_months_array, @month_count+1)

    # correct last two months since the data of last+1 and last+2 are not available for avg
    correct_last_two_months(@actions_done_avg_last_months_array, @month_count)
    correct_last_two_months(@actions_created_avg_last_months_array, @month_count)

    # interpolate avg for this month.
    percent_of_month = Time.zone.now.day.to_f / Time.zone.now.end_of_month.day.to_f
    @interpolated_actions_created_this_month = interpolate_avg(@actions_created_last_months_array, percent_of_month)
    @interpolated_actions_done_this_month = interpolate_avg(@actions_done_last_months_array, percent_of_month)

    render :layout => false
  end

  def actions_done_last30days_data
    # get actions created and completed in the past 30 days.
    @actions_done_last30days = current_user.todos.completed_after(@cut_off_month).find(:all, { :select => "completed_at" })
    @actions_created_last30days = current_user.todos.created_after(@cut_off_month).find(:all, { :select => "created_at" })

    # convert to array. 30+1 to have 30 complete days and one current day [0]
    @actions_done_last30days_array = convert_to_array(convert_to_hash(@actions_done_last30days, :difference_in_days, :completed_at), 31)
    @actions_created_last30days_array = convert_to_array(convert_to_hash(@actions_created_last30days, :difference_in_days, :created_at), 31)

    # find max for graph in both hashes
    @max = [@actions_done_last30days_array.max, @actions_created_last30days_array.max].max

    render :layout => false
  end

  def actions_completion_time_data
    @actions_completion_time = current_user.todos.completed.find(:all, { :select => "completed_at, created_at", :order => "completed_at DESC" })

    # convert to array and fill in non-existing weeks with 0
    @max_weeks = difference_in_weeks(@today, @actions_completion_time.last.completed_at)
    @actions_completed_per_week_array = convert_to_array(convert_to_week_hash(@actions_completion_time), @max_weeks+1)
    
    # stop the chart after 10 weeks
    @count = [10, @max_weeks].min
    
    # convert to new array to hold max @cut_off elems + 1 for sum of actions after @cut_off
    @actions_completion_time_array = cut_off_array(@actions_completed_per_week_array, @count)
    @max_actions = @actions_completion_time_array.max

    # get percentage done cummulative
    @cumm_percent_done = convert_to_cummulative_array(@actions_completion_time_array, @actions_completion_time.count)

    render :layout => false
  end

  def actions_running_time_data
    @actions_running_time = current_user.todos.not_completed.find(:all, { :select => "created_at", :order => "created_at DESC" })

    # convert to array and fill in non-existing weeks with 0
    @max_weeks = difference_in_weeks(@today, @actions_running_time.last.created_at)
    @actions_running_per_week_array = convert_to_array(convert_to_week_hash_today(@actions_running_time), @max_weeks+1)

    # cut off chart at 52 weeks = one year
    @count = [52, @max_weeks].min
    
    # convert to new array to hold max @cut_off elems + 1 for sum of actions after @cut_off
    @actions_running_time_array = cut_off_array(@actions_running_per_week_array, @count)
    @max_actions = @actions_running_time_array.max

    # get percentage done cummulative
    @cumm_percent_done = convert_to_cummulative_array(@actions_running_time_array, @actions_running_time.count )
      
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

    @actions_running_time = current_user.todos.not_completed.not_hidden.not_deferred_or_blocked.find(
      :all, :select => "todos.created_at", :order => "todos.created_at DESC")

    @max_weeks = difference_in_weeks(@today, @actions_running_time.last.created_at)
    @actions_running_per_week_array = convert_to_array(convert_to_week_hash_today(@actions_running_time), @max_weeks+1)

    # cut off chart at 52 weeks = one year
    @count = [52, @max_weeks].min
    
    # convert to new array to hold max @cut_off elems + 1 for sum of actions after @cut_off
    @actions_running_time_array = cut_off_array(@actions_running_per_week_array, @count)
    @max_actions = @actions_running_time_array.max

    # get percentage done cummulative
    @cumm_percent_done = convert_to_cummulative_array(@actions_running_time_array, @actions_running_time.count )

    render :layout => false
  end

  def context_total_actions_data
    # get total action count per context Went from GROUP BY c.id to c.name for
    # compatibility with postgresql. Since the name is forced to be unique, this
    # should work.
    @all_actions_per_context = current_user.contexts.find_by_sql(
      "SELECT c.name AS name, c.id as id, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id "+
        "AND c.user_id = #{current_user.id} " +
        "GROUP BY c.name, c.id "+
        "ORDER BY total DESC"
    )
    @sum = @all_actions_per_context.inject(0){|sum, apc| sum += apc['total'].to_i }
    
    pie_cutoff=10
    size = [@all_actions_per_context.size, pie_cutoff].min
    
    # explicitely copy contents of hash to avoid ending up with two arrays pointing to same hashes
    @actions_per_context = Array.new(size){|i| {
      'name' => @all_actions_per_context[i][:name],
      'total' => @all_actions_per_context[i][:total].to_i,
      'id' => @all_actions_per_context[i][:id]
      } }

    if size==pie_cutoff
      @actions_per_context[size-1]['name']=t('stats.other_actions_label')
      @actions_per_context[size-1]['total']=@actions_per_context[size-1]['total']
      @actions_per_context[size-1]['id']=-1
      size.upto(@all_actions_per_context.size-1){ |i| @actions_per_context[size-1]['total']+=(@all_actions_per_context[i]['total'].to_i) }
    end
    
    @truncate_chars = 15

    render :layout => false
  end

  def context_running_actions_data
    # get incomplete action count per visible context
    #
    # Went from GROUP BY c.id to c.name for compatibility with postgresql. Since
    # the name is forced to be unique, this should work.
    @all_actions_per_context = current_user.contexts.find_by_sql(
      "SELECT c.name AS name, c.id as id, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id AND t.completed_at IS NULL AND NOT c.hide "+
        "GROUP BY c.name, c.id "+
        "ORDER BY total DESC"
    )

    pie_cutoff=10
    size = @all_actions_per_context.size()
    size = pie_cutoff if size > pie_cutoff
    @actions_per_context = Array.new(size)
    0.upto size-1 do |i|
      @actions_per_context[i] = @all_actions_per_context[i]
    end

    if size==pie_cutoff
      @actions_per_context[size-1]['name']=t('stats.other_actions_label')
      @actions_per_context[size-1]['total']=0
      @actions_per_context[size-1]['id']=-1
      (size-1).upto @all_actions_per_context.size()-1 do |i|
        @actions_per_context[size-1]['total']+=@all_actions_per_context[i]['total'].to_i
      end
    end

    @sum = @all_actions_per_context.inject(0){|sum, apc| sum += apc['total'].to_i }
    @truncate_chars = 15

    render :layout => false
  end

  def actions_day_of_week_all_data
    @actions_creation_day = current_user.todos.find(:all, { :select => "created_at" })
    @actions_completion_day = current_user.todos.completed.find(:all, { :select => "completed_at" })

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
    @actions_creation_day = current_user.todos.created_after(@cut_off_month).find(:all, { :select => "created_at" })
    @actions_completion_day = current_user.todos.completed_after(@cut_off_month).find(:all, { :select => "completed_at" })

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
    @actions_creation_hour = current_user.todos.find(:all, { :select => "created_at" })
    @actions_completion_hour = current_user.todos.completed.find(:all, { :select => "completed_at" })

    # convert to hash to be able to fill in non-existing days
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each do |r|
      hour = r.created_at.hour
      @actions_creation_hour_array[hour] += 1
    end

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each do |r|
      hour = r.completed_at.hour
      @actions_completion_hour_array[hour] += 1
    end

    @max = [@actions_creation_hour_array.max, @actions_completion_hour_array.max].max

    render :layout => false
  end

  def actions_time_of_day_30days_data
    @actions_creation_hour = current_user.todos.created_after(@cut_off_month).find(:all, { :select => "created_at" })
    @actions_completion_hour = current_user.todos.completed_after(@cut_off_month).find(:all, { :select => "completed_at" })

    # convert to hash to be able to fill in non-existing days
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each do |r|
      hour = r.created_at.hour
      @actions_creation_hour_array[hour] += 1
    end

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each do |r|
      hour = r.completed_at.hour
      @actions_completion_hour_array[hour] += 1
    end

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

      @chart_name = "actions_visible_running_time_data"
      @page_title = t('stats.actions_selected_from_week')
      @further = false
      if params['id'] == 'avrt_end'
        @page_title += week_from.to_s + t('stats.actions_further')
        @further = true
      else
        @page_title += week_from.to_s + " - " + week_to.to_s + ""
      end

      # get all running actions that are visible
      @actions_running_time = current_user.todos.find_by_sql([
          "SELECT t.id, t.created_at "+
            "FROM todos t LEFT OUTER JOIN projects p ON t.project_id = p.id LEFT OUTER JOIN contexts c ON t.context_id = c.id "+
            "WHERE t.completed_at IS NULL " +
            "AND t.show_from IS NULL " +
            "AND NOT (p.state='hidden' OR c.hide=?) " +
            "ORDER BY t.created_at ASC", true]
      )

      @selected_todo_ids, @count = get_ids_from(@actions_running_time, week_from, week_to, params['id']== 'avrt_end')
      @selected_actions = current_user.todos.find(:all, {
          :conditions => "id in (" + @selected_todo_ids + ")"
        })

      render :action => "show_selection_from_chart"

    when 'art', 'art_end'
      week_from = params['index'].to_i
      week_to = week_from+1

      @chart_name = "actions_running_time_data"
      @page_title = "Actions selected from week "
      @further = false
      if params['id'] == 'art_end'
        @page_title += week_from.to_s + " and further"
        @further = true
      else
        @page_title += week_from.to_s + " - " + week_to.to_s + ""
      end

      # get all running actions
      @actions_running_time = current_user.todos.not_completed.find(:all, { :select => "id, created_at" })

      @selected_todo_ids, @count = get_ids_from(@actions_running_time, week_from, week_to, params['id']=='art_end')
      @selected_actions = current_user.todos.find(:all, { :conditions => "id in (" + @selected_todo_ids + ")" })

      render :action => "show_selection_from_chart"
    else
      # render error
      render_failure "404 NOT FOUND. Unknown query selected"
    end
  end

  def done
    @source_view = 'done'

    init_not_done_counts

    @done_recently = current_user.todos.completed.all(:limit => 10, :order => 'completed_at DESC', :include => Todo::DEFAULT_INCLUDES)
    @last_completed_projects = current_user.projects.completed.all(:limit => 10, :order => 'completed_at DESC', :include => [:todos, :notes])
    @last_completed_contexts = []
    @last_completed_recurring_todos = current_user.recurring_todos.completed.all(:limit => 10, :order => 'completed_at DESC', :include => [:tags, :taggings])
    #TODO: @last_completed_contexts = current_user.contexts.completed.all(:limit => 10, :order => 'completed_at DESC')
  end

  private

  def get_unique_tags_of_user
    tag_ids = current_user.todos.find_by_sql([
        "SELECT DISTINCT tags.id as id "+
          "FROM tags, taggings, todos "+
          "WHERE tags.id = taggings.tag_id " +
          "AND taggings.taggable_id = todos.id "])
    tags_ids_s = tag_ids.map(&:id).sort.join(",")
    return {} if tags_ids_s.blank?  # return empty hash for .size to work
    return Tag.find(:all, :conditions => "id in (" + tags_ids_s + ")")
  end

  def get_total_number_of_tags_of_user
    # same query as get_unique_tags_of_user except for the DISTINCT
    return current_user.todos.find_by_sql([
        "SELECT tags.id as id "+
          "FROM tags, taggings, todos "+
          "WHERE tags.id = taggings.tag_id " +
          "AND taggings.taggable_id = todos.id "]).size
  end

  def init
    @me = self # for meta programming

    # default chart dimensions
    @chart_width=460
    @chart_height=250
    @pie_width=@chart_width
    @pie_height=325

    # get the current date wih time set to 0:0
    @today = Time.zone.now.beginning_of_day

    # define the number of seconds in a day
    @seconds_per_day = 60*60*24

    # define cut_off date and discard the time for a month, 3 months and a year
    @cut_off_year = 13.months.ago.beginning_of_day
    @cut_off_year_plus3 = 16.months.ago.beginning_of_day
    @cut_off_month = 1.month.ago.beginning_of_day
    @cut_off_3months = 3.months.ago.beginning_of_day
  end

  def get_stats_actions
    # time to complete
    @completed_actions = current_user.todos.completed.find(:all, { :select => "completed_at, created_at" })

    actions_sum, actions_max, actions_min = 0,0,-1
    @completed_actions.each do |r|
      actions_sum += (r.completed_at - r.created_at)
      actions_max = [(r.completed_at - r.created_at), actions_max].max

      actions_min = (r.completed_at - r.created_at) if actions_min == -1
      actions_min = [(r.completed_at - r.created_at), actions_min].min
    end

    sum_actions = @completed_actions.size
    sum_actions = 1 if sum_actions==0

    @actions_avg_ttc = (actions_sum/sum_actions)/@seconds_per_day
    @actions_max_ttc = actions_max/@seconds_per_day
    @actions_min_ttc = actions_min/@seconds_per_day

    min_ttc_sec = Time.utc(2000,1,1,0,0)+actions_min
    @actions_min_ttc_sec = (min_ttc_sec).strftime("%H:%M:%S")
    @actions_min_ttc_sec = (actions_min / @seconds_per_day).round.to_s + " days " + @actions_min_ttc_sec if actions_min > @seconds_per_day

    # get count of actions created and actions done in the past 30 days.
    @sum_actions_done_last30days = current_user.todos.completed.completed_after(@cut_off_month).count(:all)
    @sum_actions_created_last30days = current_user.todos.created_after(@cut_off_month).count(:all)

    # get count of actions done in the past 12 months.
    @sum_actions_done_last12months = current_user.todos.completed.completed_after(@cut_off_year).count(:all)
    @sum_actions_created_last12months = current_user.todos.created_after(@cut_off_year).count(:all)
  end

  def get_stats_contexts
    # get action count per context for TOP 5
    #
    # Went from GROUP BY c.id to c.id, c.name for compatibility with postgresql.
    # Since the name is forced to be unique, this should work.
    @actions_per_context = current_user.contexts.find_by_sql(
      "SELECT c.id AS id, c.name AS name, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id "+
        "GROUP BY c.id, c.name ORDER BY total DESC " +
        "LIMIT 5"
    )

    # get incomplete action count per visible context for TOP 5
    #
    # Went from GROUP BY c.id to c.id, c.name for compatibility with postgresql.
    # Since the name is forced to be unique, this should work.
    @running_actions_per_context = current_user.contexts.find_by_sql(
      "SELECT c.id AS id, c.name AS name, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id AND t.completed_at IS NULL AND NOT c.hide "+
        "GROUP BY c.id, c.name ORDER BY total DESC " +
        "LIMIT 5"
    )
  end

  def get_stats_projects
    # get the first 10 projects and their action count (all actions)
    #
    # Went from GROUP BY p.id to p.name for compatibility with postgresql. Since
    # the name is forced to be unique, this should work.
    @projects_and_actions = current_user.projects.find_by_sql(
      "SELECT p.id, p.name, count(*) AS count "+
        "FROM projects p, todos t "+
        "WHERE p.id = t.project_id "+
        "GROUP BY p.id, p.name "+
        "ORDER BY count DESC " +
        "LIMIT 10"
    )

    # get the first 10 projects with their actions count of actions that have
    # been created or completed the past 30 days

    # using GROUP BY p.name (was: p.id) for compatibility with Postgresql. Since
    # you cannot create two contexts with the same name, this will work.
    @projects_and_actions_last30days = current_user.projects.find_by_sql([
        "SELECT p.id, p.name, count(*) AS count "+
          "FROM todos t, projects p "+
          "WHERE t.project_id = p.id AND "+
          "      (t.created_at > ? OR t.completed_at > ?) "+
          "GROUP BY p.id, p.name "+
          "ORDER BY count DESC " +
          "LIMIT 10", @cut_off_month, @cut_off_month]
    )

    # get the first 10 projects and their running time (creation date versus
    # now())
    @projects_and_runtime_sql = current_user.projects.find_by_sql(
      "SELECT id, name, created_at "+
        "FROM projects "+
        "WHERE state='active' "+
        "AND user_id="+@user.id.to_s+" "+
        "ORDER BY created_at ASC "+
        "LIMIT 10"
    )

    i=0
    @projects_and_runtime = Array.new(10, [-1, "n/a", "n/a"])
    @projects_and_runtime_sql.each do |r|
      days = (@today - r.created_at) / @seconds_per_day
      # add one so that a project that you just create returns 1 day
      @projects_and_runtime[i]=[r.id, r.name, days.to_i+1]
      i += 1
    end

  end

  def get_stats_tags
    # tag cloud code inspired by this article
    #  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/

    levels=10
    # TODO: parameterize limit

    # Get the tag cloud for all tags for actions
    query = "SELECT tags.id, name, count(*) AS count"
    query << " FROM taggings, tags, todos"
    query << " WHERE tags.id = tag_id"
    query << " AND taggings.taggable_id = todos.id"
    query << " AND todos.user_id="+current_user.id.to_s+" "
    query << " AND taggings.taggable_type='Todo' "
    query << " GROUP BY tags.id, tags.name"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
    @tags_for_cloud = Tag.find_by_sql(query).sort_by { |tag| tag.name.downcase }

    max, @tags_min = 0, 0
    @tags_for_cloud.each { |t|
      max = [t.count.to_i, max].max
      @tags_min = [t.count.to_i, @tags_min].min
    }

    @tags_divisor = ((max - @tags_min) / levels) + 1

    # Get the tag cloud for all tags for actions
    query = "SELECT tags.id, tags.name AS name, count(*) AS count"
    query << " FROM taggings, tags, todos"
    query << " WHERE tags.id = tag_id"
    query << " AND todos.user_id=? "
    query << " AND taggings.taggable_type='Todo' "
    query << " AND taggings.taggable_id=todos.id "
    query << " AND (todos.created_at > ? OR "
    query << "      todos.completed_at > ?) "
    query << " GROUP BY tags.id, tags.name"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
    @tags_for_cloud_90days = Tag.find_by_sql(
      [query, current_user.id, @cut_off_3months, @cut_off_3months]
    ).sort_by { |tag| tag.name.downcase }

    max_90days, @tags_min_90days = 0, 0
    @tags_for_cloud_90days.each { |t|
      max_90days = [t.count.to_i, max_90days].max
      @tags_min_90days = [t.count.to_i, @tags_min_90days].min
    }

    @tags_divisor_90days = ((max_90days - @tags_min_90days) / levels) + 1

  end

  def get_ids_from (actions_running_time, week_from, week_to, at_end)
    count=0
    selected_todo_ids = ""

    actions_running_time.each do |r|
      days = (@today - r.created_at) / @seconds_per_day
      weeks = (days/7).to_i
      if at_end
        if weeks >= week_from
          selected_todo_ids += r.id.to_s+","
          count+=1
        end
      else
        if weeks.between?(week_from, week_to-1)
          selected_todo_ids += r.id.to_s+","
          count+=1
        end
      end
    end

    # strip trailing comma
    selected_todo_ids = selected_todo_ids[0..selected_todo_ids.length-2]

    return selected_todo_ids, count
  end

  def convert_to_array(hash, upper_bound)
    return Array.new(upper_bound){ |i| hash[i] }
  end

  def convert_to_hash(records, difference_method, date_method_on_todo)
    # use 0 to initialise action count to zero
    hash = Hash.new(0)
    records.each { |t| hash[self.send(difference_method, @today, t.send(date_method_on_todo))] += 1 }
    return hash
  end

  def convert_to_week_hash(records)
    hash = Hash.new(0)
    records.each do |r|
      index = difference_in_weeks(r.completed_at, r.created_at)
      hash[index] += 1
    end
    return hash
  end
  
  def convert_to_week_hash_today(records)
    hash = Hash.new(0)
    records.each do |r|
      index = difference_in_weeks(@today, r.created_at)
      hash[index] += 1
    end
    return hash
  end

  # returns a new array containing all elems of array up to cut_off and
  # adds the sum of the rest of array to the last elem
  def cut_off_array(array, cut_off)
    # +1 to hold sum of rest
    a = Array.new(cut_off+1){|i| array[i]||0}
    # add rest of array to last elem
    a[cut_off] += array.inject(:+) - a.inject(:+)
    return a
  end

  def convert_to_cummulative_array(array, max)
    # calculate fractions
    a = Array.new(array.size){|i| array[i]*100.0/max}
    # make cummulative
    1.upto(array.size-1){ |i| a[i] += a[i-1] }
    return a
  end

  # assumes date1 > date2
  # this results in the number of months before the month of date1, not taking days into account, so diff of 31-12 and 1-1 is 1 month!
  def difference_in_months(date1, date2)
    return (date1.year - date2.year)*12 + (date1.month - date2.month)
  end

  # assumes date1 > date2
  def difference_in_days(date1, date2)
    return ((date1.at_midnight-date2.at_midnight)/@seconds_per_day).to_i
  end
  
  # assumes date1 > date2
  def difference_in_weeks(date1, date2)
    return difference_in_days(date1, date2) / 7
  end

  def three_month_avg(set, i)
    return ( (set[i]||0) + (set[i+1]||0) + (set[i+2]||0) ) / 3.0
  end

  def interpolate_avg(set, percent)
    return (set[0]*percent + set[1] + set[2]) / 3.0
  end

  def correct_last_two_months(month_data, count)
    month_data[count] = month_data[count] * 3
    month_data[count-1] = month_data[count-1] * 3 / 2 if count > 1
  end

  def find_running_avg_array(done_array, created_array, upper_bound)
    avg_done    = Array.new(upper_bound){ |i| three_month_avg(done_array,i) }
    avg_created = Array.new(upper_bound){ |i| three_month_avg(created_array,i) }
    avg_done[0] = avg_created[0] = "null"
    
    return avg_done, avg_created
  end

end