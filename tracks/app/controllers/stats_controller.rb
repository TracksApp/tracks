class StatsController < ApplicationController
  
  def index
    @page_title = 'TRACKS::Statistics'
    
    @projects = @user.projects
    @contexts = @user.contexts
    @actions = @user.todos
    @tags = @user.tags
    
    @unique_tags = @tags.find(:all, {:group=>"tag_id"})
    @hidden_contexts = @contexts.select{ |c| c.hide? }
    @first_action = @actions.find(:first, :order => "created_at asc")
    
    # default chart dimensions
    @chart_width=450
    @chart_height=250
    @pie_width=@chart_width
    @pie_height=325
    
    get_stats_actions
    get_stats_contexts
    get_stats_projects
    get_stats_tags   
      
    render :layout => 'standard'
  end  
  
  def actions_done_last12months_data
    @actions = @user.todos
    
    @actions_done_last12months = @actions.count(
      :all, {
        :group => "period_diff(extract(year_month from now()), extract(year_month from completed_at))", 
        :conditions => "period_diff(extract(year_month from now()), extract(year_month from completed_at)) <= 12  and not completed_at is null" 
      })
    @actions_created_last12months = @actions.count(:all, {
        :group => "period_diff(extract(year_month from now()), extract(year_month from created_at))", 
        :conditions => "period_diff(extract(year_month from now()), extract(year_month from created_at)) <= 12" 
      })

    # find max count for graph
    @max=0

    # convert to hash to be able to fill in non-existing days in
    # @actions_done_last12months
    @sum_actions_done_last12months=0      
    @actions_done_last12months_hash = Hash.new(0)
    @actions_done_last12months.each do |month, count|
      @actions_done_last12months_hash[month] = count
      @sum_actions_done_last12months+= count.to_i      
      @max = count.to_i if count.to_i > @max
    end

    @sum_actions_created_last12months=0
    @actions_created_last12months_hash = Hash.new(0)
    @actions_created_last12months.each do |month, count|
      @actions_created_last12months_hash[month] = count
      @sum_actions_created_last12months+= count.to_i
      @max = count.to_i if count.to_i > @max
    end
      
    render :layout => false
  end

  def actions_done_last30days_data
    @actions = @user.todos

    # get count of actions done in the past 30 days. Results in a array of
    # arrays
    @actions_done_last30days = @actions.count(:all, {
        :group => "datediff(now(), completed_at)", 
        :conditions => "datediff(now(), completed_at) <= 30  and not completed_at is null" 
      })
    @actions_created_last30days = @actions.count(:all, {
        :group => "datediff(now(), created_at)",
        :conditions => "datediff(now(), created_at) <= 30"
      })

    # find max for graph
    @max=0
    
    # convert to hash to be albe to fill in non-existing days in
    # @actions_done_last30days
    @sum_actions_done_last30days=0
      
    @actions_done_last30days_hash = Hash.new(0)
    @actions_done_last30days.each do |day, count|
      @actions_done_last30days_hash[day] = count
      @sum_actions_done_last30days+= count.to_i
      @max = count.to_i if count.to_i > @max
    end

    # convert to hash to be albe to fill in non-existing days in
    # @actions_done_last30days
    @sum_actions_created_last30days=0

    @actions_created_last30days_hash = Hash.new(0)
    @actions_created_last30days.each do |day, count|
      @actions_created_last30days_hash[day] = count
      @sum_actions_created_last30days+= count.to_i
      @max = count.to_i if count.to_i > @max
    end
      
    render :layout => false
  end

  def actions_completion_time_data
    @actions = @user.todos
          
    @actions_completion_time = @actions.count(:all, {
        :group => "datediff(completed_at, created_at)", 
        :conditions => "not completed_at is null", 
        :order => "datediff(completed_at, created_at) ASC" 
      })

    # convert to hash to be able to fill in non-existing days in
    # @actions_completion_time also convert days to weeks (/7)
       
    @max_days, @max_actions=0,0
    @actions_completion_time_hash = Hash.new(0)
    @actions_completion_time.each do |days, total|
      # RAILS_DEFAULT_LOGGER.error("\n" + total.to_s + " - " + days + "\n")
      @actions_completion_time_hash[days.to_i/7] = @actions_completion_time_hash[days.to_i/7] + total     
      
      @max_days=days.to_i if days.to_i > @max_days
      @max_actions = @actions_completion_time_hash[days.to_i/7] if @actions_completion_time_hash[days.to_i/7] > @max_actions
    end
          
    # stop the chart after 10 weeks
    @cut_off = 10
          
    render :layout => false
  end

  def actions_running_time_data
    @actions = @user.todos
          
    @actions_running_time = @actions.count(:all, {
        :group => "datediff(now(), created_at)", 
        :conditions => "completed_at is null", 
        :order => "datediff(now(), created_at) ASC" 
      })

    # convert to hash to be able to fill in non-existing days in
    # @actions_running_time also convert days to weeks (/7)
           
    @max_days, @max_actions=0,0
    @actions_running_time_hash = Hash.new(0)
    @actions_running_time.each do |days, total|
      # RAILS_DEFAULT_LOGGER.error("\n" + total.to_s + " - " + days + "\n")
      @actions_running_time_hash[days.to_i/7] = @actions_running_time_hash[days.to_i/7] + total
      
      @max_days=days.to_i if days.to_i > @max_days
      @max_actions = @actions_running_time_hash[days.to_i/7] if @actions_running_time_hash[days.to_i/7] > @max_actions
    end
                    
    # cut off chart at 52 weeks = one year
    @cut_off=52
            
    render :layout => false
  end

  def actions_visible_running_time_data
    @actions = @user.todos
          
    @actions_running_time = @actions.count(:all, {
        :group => "datediff(now(), created_at)", 
        :conditions => "completed_at is null", 
        :order => "datediff(now(), created_at) ASC" 
      })

    @actions_running_time = @actions.find_by_sql(
      "SELECT datediff(now(), t.created_at) AS days, count(*) AS total "+
        "FROM todos t LEFT OUTER JOIN projects p ON t.project_id = p.id LEFT OUTER JOIN contexts c ON t.context_id = c.id "+
        "WHERE t.user_id="+@user.id.to_s+" "+
        "AND t.completed_at is null " +
        "AND NOT (p.state='hidden' OR c.hide=1) " +
        "GROUP BY days ORDER BY days DESC"
    )
    
    # convert to hash to be able to fill in non-existing days in
    # @actions_running_time also convert days to weeks (/7)
           
    @max_days, @max_actions=0,0
    @actions_running_time_hash = Hash.new(0)
    @actions_running_time.each do |a|
      # RAILS_DEFAULT_LOGGER.error("\n" + total.to_s + " - " + days + "\n")
      @actions_running_time_hash[a.days.to_i/7] += a.total.to_i
      
      @max_days=a.days.to_i if a.days.to_i > @max_days
      @max_actions = @actions_running_time_hash[a.days.to_i/7] if @actions_running_time_hash[a.days.to_i/7] > @max_actions
    end
                    
    # cut off chart at 52 weeks = one year
    @cut_off=52
            
    render :layout => false
  end

  
  def context_total_actions_data
    @contexts = @user.contexts
            
    # get total action count per context
    @actions_per_context = @contexts.find_by_sql(
      "SELECT c.name AS name, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id "+
        "AND t.user_id="+@user.id.to_s+" "+
        "GROUP BY c.id "+
        "ORDER BY total DESC"
    )
            
    @sum=0
    0.upto @actions_per_context.size()-1 do |i|
      @sum += @actions_per_context[i]['total'].to_i
    end
            
    render :layout => false
  end

  def context_running_actions_data
    @contexts = @user.contexts
            
            
    # get uncompleted action count per visible context
    @actions_per_context = @contexts.find_by_sql(
      "SELECT c.name AS name, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id AND t.completed_at IS NULL AND NOT c.hide "+
        "AND t.user_id="+@user.id.to_s+" "+
        "GROUP BY c.id "+
        "ORDER BY total DESC"
    )
            
    @sum=0
    0.upto @actions_per_context.size()-1 do |i|
      @sum += @actions_per_context[i]['total'].to_i
    end
            
    render :layout => false
  end

  def actions_day_of_week_all_data
    @actions = @user.todos
          
    @actions_creation_day = @actions.count(:all, {
        :group => "dayofweek(created_at)" 
      })
    
    @actions_completion_day = @actions.count(:all, {
        :group => "dayofweek(completed_at)", 
        :conditions => "not completed_at is null" 
      })

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_day_array = Array.new(7) { |i| 0}
    @actions_creation_day.each do |dayofweek, total|
      # dayofweek: sunday=1..saterday=7
      @max = total.to_i if total.to_i > @max
      @actions_creation_day_array[dayofweek.to_i-1]=total.to_i
    end

    # convert to hash to be able to fill in non-existing days
    @actions_completion_day_array = Array.new(7) { |i| 0}
    @actions_completion_day.each do |dayofweek, total|
      # dayofweek: sunday=1..saterday=7
      @max = total.to_i if total.to_i > @max 
      @actions_completion_day_array[dayofweek.to_i-1]=total.to_i
    end
                      
    render :layout => false
  end

  def actions_day_of_week_30days_data
    @actions = @user.todos
          
    @actions_creation_day = @actions.count(:all, {
        :group => "dayofweek(created_at)",
        :conditions => "datediff(now(), created_at) <= 30" 
      })
        
    @actions_completion_day = @actions.count(:all, {
        :group => "dayofweek(completed_at)", 
        :conditions => "not completed_at is null and datediff(now(), created_at) <= 30" 
      })

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_day_array = Array.new(7) { |i| 0}
    @actions_creation_day.each do |dayofweek, total|
      # dayofweek: sunday=1..saterday=7
      @max = total.to_i if total.to_i > @max
      @actions_creation_day_array[dayofweek.to_i-1]=total.to_i
    end

    # convert to hash to be able to fill in non-existing days
    @actions_completion_day_array = Array.new(7) { |i| 0}
    @actions_completion_day.each do |dayofweek, total|
      # dayofweek: sunday=1..saterday=7
      @max = total.to_i if total.to_i > @max 
      @actions_completion_day_array[dayofweek.to_i-1]=total.to_i
    end
                      
    render :layout => false
  end

  def actions_time_of_day_all_data
    @actions = @user.todos
          
    # TODO: these queries needs a parameter for current time zone. Currently its
    # setup for europe/amsterdam summertime
    @actions_creation_hour = @actions.count(:all, {
        :group => "hour(convert_tz(created_at, @@session.time_zone, '+2:00'))" 
      })
    
    @actions_completion_hour = @actions.count(:all, {
        :group => "hour(convert_tz(created_at, @@session.time_zone, '+2:00'))", 
        :conditions => "not completed_at is null" 
      })

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each do |hour, total|
      @max = total.to_i if total.to_i > @max 
      @actions_creation_hour_array[hour.to_i]=total.to_i
    end

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each do |hour, total|              
      @max = total.to_i if total.to_i > @max 
      @actions_completion_hour_array[hour.to_i]=total.to_i
    end
                      
    render :layout => false
  end

  def actions_time_of_day_30days_data
    @actions = @user.todos
          
    # TODO: find out how to find current timezone
    @actions_creation_hour = @actions.count(
      :all, {
        :group => "hour(convert_tz(created_at, @@session.time_zone, '+2:00'))",
        :conditions => "datediff(now(), created_at) <= 30" 
      })
        
    # TODO: find out how to find current timezone
    @actions_completion_hour = @actions.count(
      :all, {:group => "hour(convert_tz(completed_at, @@session.time_zone, '+2:00'))", 
        :conditions => "not completed_at is null and datediff(now(), completed_at) <= 30" 
      })

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each do |hour, total|
      @max = total.to_i if total.to_i > @max
      @actions_creation_hour_array[hour.to_i]=total.to_i
    end

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each do |hour, total|              
      @max = total.to_i if total.to_i > @max
      @actions_completion_hour_array[hour.to_i]=total.to_i
    end
                      
    render :layout => false
  end

  private
  
  def get_stats_actions
    # time to complete
    @actions_avg_ttc = @actions.average("datediff(completed_at, created_at)", {:conditions => "not completed_at is null"} )
    @actions_max_ttc = @actions.maximum("datediff(completed_at, created_at)", {:conditions => "not completed_at is null"} )
    @actions_min_ttc = @actions.minimum("datediff(completed_at, created_at)", {:conditions => "not completed_at is null"} )
    @actions_min_ttc_sec = @actions.minimum("timediff(completed_at, created_at)", {:conditions => "not completed_at is null"} )
    
    # get count of actions created and actions done in the past 30 days.
    @sum_actions_done_last30days = @actions.count(:all, {
        :conditions => "datediff(now(), completed_at) <= 30 AND NOT completed_at IS null" 
      })
    @sum_actions_created_last30days = @actions.count(:all, {
        :conditions => "datediff(now(), created_at) <= 30"
      })
    
    # get count of actions done in the past 12 months.
    @sum_actions_done_last12months = @actions.count(:all, {
        :conditions => "period_diff(extract(year_month from now()), extract(year_month from completed_at)) <= 12 AND NOT completed_at IS null" 
      })
    @sum_actions_created_last12months = @actions.count(:all, {
        :conditions => "period_diff(extract(year_month from now()), extract(year_month from created_at)) <= 12" 
      })
    
  end

  def get_stats_contexts
    # get action count per context for TOP 5
    @actions_per_context = @contexts.find_by_sql(
      "SELECT c.name AS name, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id "+
        "AND t.user_id="+@user.id.to_s+" "+
        "GROUP BY c.id ORDER BY total DESC " +
        "LIMIT 5"
    )

    # get uncompleted action count per visible context for TOP 5
    @running_actions_per_context = @contexts.find_by_sql(
      "SELECT c.name AS name, count(*) AS total "+
        "FROM contexts c, todos t "+
        "WHERE t.context_id=c.id AND t.completed_at IS NULL AND NOT c.hide "+
        "AND t.user_id="+@user.id.to_s+" "+
        "GROUP BY c.id ORDER BY total DESC " +
        "LIMIT 5"
    )    
  end

  def get_stats_projects
    # get the first 10 projects and their action count (all actions)
    @projects_and_actions = @projects.find_by_sql(
      "SELECT p.name, count(*) AS count "+
        "FROM projects p, todos t "+
        "WHERE p.id = t.project_id "+
        "AND p.user_id="+@user.id.to_s+" "+
        "GROUP BY p.id "+
        "ORDER BY count DESC " +
        "LIMIT 10"
    )
    
    # get the first 10 projects with their actions count of actions that have
    # been created or completed the past 30 days
    @projects_and_actions_last30days = @projects.find_by_sql(
      "SELECT p.name, count(*) AS count "+
        "FROM todos t, projects p "+
        "WHERE t.project_id = p.id AND "+
        "      (datediff(now(), t.created_at) < 30 OR "+
        "       datediff(now(), t.completed_at) < 30) "+
        "AND p.user_id="+@user.id.to_s+" "+
        "GROUP BY p.id "+
        "ORDER BY count DESC " +
        "LIMIT 10"
    )
    
    # get the first 10 projects and their running time (creation date versus
    # now())
    @projects_and_runtime = @projects.find_by_sql(
      "SELECT name, datediff(now(),created_at) AS days "+
        "FROM projects p "+
        "WHERE state='active' "+
        "AND p.user_id="+@user.id.to_s+" "+
        "ORDER BY days DESC "+
        "LIMIT 10"
    )
    
  end
  
  def get_stats_tags
    # tag cloud code inspired by this article
    #  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/

    # TODO: parameterize limit
    query = "SELECT tags.id, name, count(*) AS count"
    query << " FROM taggings, tags"
    query << " WHERE tags.id = tag_id"
    query << " AND taggings.user_id="+@user.id.to_s+" "
    query << " GROUP BY tag_id"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
    @tags_for_cloud = Tag.find_by_sql(query).sort_by { |tag| tag.name.downcase }
      
    max, @tags_min = 0, 0
    @tags_for_cloud.each { |t|
      max = t.count.to_i if t.count.to_i > max
      @tags_min = t.count.to_i if t.count.to_i < @tags_min
    }

    # 10 = number of levels
    @tags_divisor = ((max - @tags_min) / 10) + 1

  end
end
