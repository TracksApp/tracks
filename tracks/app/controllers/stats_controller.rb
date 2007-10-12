class StatsController < ApplicationController

  append_before_filter :init, :exclude => []
  
  def index
    @page_title = 'TRACKS::Statistics'
      
    @unique_tags = @tags.find(:all, {:group=>"tag_id"})
    @hidden_contexts = @contexts.find(:all, {:conditions => ["hide = ? ", true]})
    @first_action = @actions.find(:first, :order => "created_at ASC")
    
    # default chart dimensions
    @chart_width=460
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
       
    # get actions created and completed in the past 12+3 months. +3 for running
    # average
    @actions_done_last12months = @actions.find(:all, {
        :select => "completed_at",
        :conditions => ["completed_at > ? AND NOT completed_at is null", @cut_off_year_plus3]
      })
    @actions_created_last12months = @actions.find(:all, {
        :select => "created_at",
        :conditions => ["created_at > ?", @cut_off_year_plus3]
      })
    
    # convert to hash to be able to fill in non-existing days in
    # @actions_done_last12months and count the total actions done in the past 12
    # months to be able to calculate percentage
    
    # use 0 to initialise action count to zero
    @actions_done_last12months_hash = Hash.new(0) 
    @actions_done_last12months.each do |r|      
      months = (@today.year - r.completed_at.year)*12 + (@today.month - r.completed_at.month)

      @actions_done_last12months_hash[months] += 1
    end
        
    # convert to hash to be able to fill in non-existing days in
    # @actions_created_last12months and count the total actions done in the past
    # 12 months to be able to calculate percentage

    # use 0 to initialise action count to zero
    @actions_created_last12months_hash = Hash.new(0)
    @actions_created_last12months.each do |r|      
      months = (@today.year - r.created_at.year)*12 + (@today.month - r.created_at.month)
      
      @actions_created_last12months_hash[months] += 1
    end

    @sum_actions_done_last12months=0
    @sum_actions_created_last12months=0

    # find max for graph in both hashes
    @max=0
    0.upto 13 do |i|             
      @sum_actions_done_last12months += @actions_done_last12months_hash[i] 
      @max = @actions_done_last12months_hash[i] if @actions_done_last12months_hash[i] > @max
    end
    0.upto 13 do |i| 
      @sum_actions_created_last12months += @actions_created_last12months_hash[i]
      @max = @actions_created_last12months_hash[i] if @actions_created_last12months_hash[i] > @max
    end
    
    # find running avg for month i by calculating avg of month i and the two
    # after them. Ignore current month because you do not have full data for it
    @actions_done_avg_last12months_hash = Hash.new("null")
    1.upto(12) { |i| 
      @actions_done_avg_last12months_hash[i] = (@actions_done_last12months_hash[i] +
          @actions_done_last12months_hash[i+1] + 
          @actions_done_last12months_hash[i+2])/3.0
    }    

    # find running avg for month i by calculating avg of month i and the two
    # after them. Ignore current month because you do not have full data for it
    @actions_created_avg_last12months_hash = Hash.new("null")
    1.upto(12) { |i| 
      @actions_created_avg_last12months_hash[i] = (@actions_created_last12months_hash[i] +
          @actions_created_last12months_hash[i+1] + 
          @actions_created_last12months_hash[i+2])/3.0
    }    
    
    render :layout => false
  end

  def actions_done_last30days_data
    # get actions created and completed in the past 30 days.
    @actions_done_last30days = @actions.find(:all, {
        :select => "completed_at",
        :conditions => ["completed_at > ? AND NOT completed_at IS NULL", @cut_off_month]
      })
    @actions_created_last30days = @actions.find(:all, {
        :select => "created_at",
        :conditions => ["created_at > ?", @cut_off_month]
      })
    
    # convert to hash to be able to fill in non-existing days in
    # @actions_done_last30days and count the total actions done in the past 30
    # days to be able to calculate percentage
    @sum_actions_done_last30days=0
    
    # use 0 to initialise action count to zero
    @actions_done_last30days_hash = Hash.new(0) 
    @actions_done_last30days.each do |r|
      # only use date part of completed_at
      action_date = Time.utc(r.completed_at.year, r.completed_at.month, r.completed_at.day, 0,0)
      days = ((@today - action_date) / @seconds_per_day).to_i

      @actions_done_last30days_hash[days] += 1
      @sum_actions_done_last30days+=1      
    end
        
    # convert to hash to be able to fill in non-existing days in
    # @actions_done_last30days and count the total actions done in the past 30
    # days to be able to calculate percentage
    @sum_actions_created_last30days=0

    # use 0 to initialise action count to zero
    @actions_created_last30days_hash = Hash.new(0)
    @actions_created_last30days.each do |r|
      # only use date part of created_at
      action_date = Time.utc(r.created_at.year, r.created_at.month, r.created_at.day, 0,0)
      days = ((@today - action_date) / @seconds_per_day).to_i
      
      @actions_created_last30days_hash[days] += 1
      @sum_actions_created_last30days += 1
    end

    # find max for graph in both hashes
    @max=0
    0.upto(30) { |i| @max = @actions_done_last30days_hash[i] if @actions_done_last30days_hash[i] > @max }   
    0.upto(30) { |i| @max = @actions_created_last30days_hash[i] if @actions_created_last30days_hash[i] > @max }
      
    render :layout => false
  end

  def actions_completion_time_data
    @actions_completion_time = @actions.find(:all, {
        :select => "completed_at, created_at",
        :conditions => "not completed_at is null"
      })
    
    # convert to hash to be able to fill in non-existing days in
    # @actions_completion_time also convert days to weeks (/7)
       
    @max_days, @max_actions, @sum_actions=0,0,0
    @actions_completion_time_hash = Hash.new(0)
    @actions_completion_time.each do |r|
      days = (r.completed_at - r.created_at) / @seconds_per_day
      weeks = (days/7).to_i
      @actions_completion_time_hash[weeks] += 1     

      @max_days=days if days > @max_days
      @max_actions = @actions_completion_time_hash[weeks] if @actions_completion_time_hash[weeks] > @max_actions      
      @sum_actions += 1
    end
    
    # stop the chart after 10 weeks
    @cut_off = 10
          
    render :layout => false
  end

  def actions_running_time_data
    @actions_running_time = @actions.find(:all, {
        :select => "created_at",
        :conditions => "completed_at is null"
      })

    # convert to hash to be able to fill in non-existing days in
    # @actions_running_time also convert days to weeks (/7)
           
    @max_days, @max_actions, @sum_actions=0,0,0
    @actions_running_time_hash = Hash.new(0)
    @actions_running_time.each do |r|
      days = (@today - r.created_at) / @seconds_per_day
      weeks = (days/7).to_i

      @actions_running_time_hash[weeks] += 1
      
      @max_days=days if days > @max_days
      @max_actions = @actions_running_time_hash[weeks] if @actions_running_time_hash[weeks] > @max_actions
      @sum_actions += 1
    end
                    
    # cut off chart at 52 weeks = one year
    @cut_off=52
            
    render :layout => false
  end

  def actions_visible_running_time_data
    @actions_running_time = @actions.find_by_sql([
        "SELECT t.created_at "+
          "FROM todos t LEFT OUTER JOIN projects p ON t.project_id = p.id LEFT OUTER JOIN contexts c ON t.context_id = c.id "+
          "WHERE t.user_id=? "+
          "AND t.completed_at is null " +
          "AND NOT (p.state='hidden' OR c.hide=?) " +
          "ORDER BY t.created_at ASC", @user.id, true]
    )
    
    # convert to hash to be able to fill in non-existing days in
    # @actions_running_time also convert days to weeks (/7)
           
    @max_days, @max_actions, @sum_actions=0,0,0
    @actions_running_time_hash = Hash.new(0)
    @actions_running_time.each do |r|
      days = (@today - r.created_at) / @seconds_per_day
      weeks = (days/7).to_i
      # RAILS_DEFAULT_LOGGER.error("\n" + total.to_s + " - " + days + "\n")
      @actions_running_time_hash[weeks] += 1
      
      @max_days=days if days > @max_days
      @max_actions = @actions_running_time_hash[weeks] if @actions_running_time_hash[weeks] > @max_actions
      @sum_actions += 1
    end
                    
    # cut off chart at 52 weeks = one year
    @cut_off=52
            
    render :layout => false
  end

  
  def context_total_actions_data
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
          
    @actions_creation_day = @actions.find(:all, {
        :select => "created_at"
      })
    
    @actions_completion_day = @actions.find(:all, {
        :select => "completed_at",
        :conditions => "not completed_at is null" 
      })

    # convert to hash to be able to fill in non-existing days
    @actions_creation_day_array = Array.new(7) { |i| 0}
    @actions_creation_day.each do |t|
      # dayofweek: sunday=0..saterday=6
      dayofweek = t.created_at.wday
      @actions_creation_day_array[dayofweek] += 1
    end
    # find max
    @max=0
    0.upto(6) { |i| @max = @actions_creation_day_array[i] if @actions_creation_day_array[i] >  @max}
      

    # convert to hash to be able to fill in non-existing days
    @actions_completion_day_array = Array.new(7) { |i| 0}
    @actions_completion_day.each do |t|
      # dayofweek: sunday=0..saterday=6
      dayofweek = t.completed_at.wday
      @actions_completion_day_array[dayofweek] += 1
    end
    0.upto(6) { |i| @max = @actions_completion_day_array[i] if @actions_completion_day_array[i] >  @max}
                      
    render :layout => false
  end

  def actions_day_of_week_30days_data
    @actions_creation_day = @actions.find(:all, {
        :select => "created_at",
        :conditions => ["created_at > ?", @cut_off_month]
      })
        
    @actions_completion_day = @actions.find(:all, {
        :select => "completed_at",
        :conditions => ["NOT completed_at IS NULL AND completed_at > ?", @cut_off_month]
      })

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_day_array = Array.new(7) { |i| 0}
    @actions_creation_day.each do |r|
      # dayofweek: sunday=1..saterday=8
      dayofweek = r.created_at.wday
      @actions_creation_day_array[dayofweek] += 1
    end
    0.upto(6) { |i| @max = @actions_creation_day_array[i] if @actions_creation_day_array[i] >  @max}

    # convert to hash to be able to fill in non-existing days
    @actions_completion_day_array = Array.new(7) { |i| 0}
    @actions_completion_day.each do |r|
      # dayofweek: sunday=1..saterday=7
      dayofweek = r.completed_at.wday
      @actions_completion_day_array[dayofweek] += 1
    end
    0.upto(6) { |i| @max = @actions_completion_day_array[i] if @actions_completion_day_array[i] >  @max}
                      
    render :layout => false
  end

  def actions_time_of_day_all_data
    @actions_creation_hour = @actions.find(:all, {
        :select => "created_at"
      })    
    @actions_completion_hour = @actions.find(:all, {
        :select => "completed_at", 
        :conditions => "NOT completed_at IS NULL" 
      })

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each do |r|
      hour = current_user.prefs.tz.adjust(r.created_at).hour
      @actions_creation_hour_array[hour] += 1
    end
    0.upto(23) { |i| @max = @actions_creation_hour_array[i] if @actions_creation_hour_array[i] >  @max}

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each do |r|              
      hour = current_user.prefs.tz.adjust(r.completed_at).hour
      @actions_completion_hour_array[hour] += 1
    end
    0.upto(23) { |i| @max = @actions_completion_hour_array[i] if @actions_completion_hour_array[i] >  @max}
                      
    render :layout => false
  end

  def actions_time_of_day_30days_data
    @actions_creation_hour = @actions.find(:all, {
        :select => "created_at",
        :conditions => ["created_at > ?", @cut_off_month]
      })
        
    @actions_completion_hour = @actions.find(:all, {
        :select => "completed_at",
        :conditions => ["NOT completed_at IS NULL AND completed_at > ?", @cut_off_month]
      })

    # convert to hash to be able to fill in non-existing days
    @max=0
    @actions_creation_hour_array = Array.new(24) { |i| 0}
    @actions_creation_hour.each do |r|
      hour = current_user.prefs.tz.adjust(r.created_at).hour
      @actions_creation_hour_array[hour] += 1
    end
    0.upto(23) { |i| @max = @actions_creation_hour_array[i] if @actions_creation_hour_array[i] >  @max}

    # convert to hash to be able to fill in non-existing days
    @actions_completion_hour_array = Array.new(24) { |i| 0}
    @actions_completion_hour.each do |r|              
      hour = current_user.prefs.tz.adjust(r.completed_at).hour
      @actions_completion_hour_array[hour] += 1
    end
    0.upto(23) { |i| @max = @actions_completion_hour_array[i] if @actions_completion_hour_array[i] >  @max}
                      
    render :layout => false
  end

  private

  def init
    @actions = @user.todos
    @projects = @user.projects
    @contexts = @user.contexts
    @tags = @user.tags
  
    # get the current date wih time set to 0:0
    now = Time.new
    @today = Time.utc(now.year, now.month, now.day, 0,0)

    # define the number of seconds in a day
    @seconds_per_day = 60*60*24

    # define cut_off date and discard the time for a month, 3 months and a year
    cut_off_time = 13.months.ago()
    @cut_off_year = Time.utc(cut_off_time.year, cut_off_time.month, cut_off_time.day,0,0)

    cut_off_time = 16.months.ago()
    @cut_off_year_plus3 = Time.utc(cut_off_time.year, cut_off_time.month, cut_off_time.day,0,0)
        
    cut_off_time = 31.days.ago
    @cut_off_month = Time.utc(cut_off_time.year, cut_off_time.month, cut_off_time.day,0,0)
    
    cut_off_time = 91.days.ago
    @cut_off_3months = Time.utc(cut_off_time.year, cut_off_time.month, cut_off_time.day,0,0)
    
  end
  
  def get_stats_actions
    # time to complete
    @completed_actions = @actions.find(:all, {
        :select => "completed_at, created_at",
        :conditions => "NOT completed_at IS NULL",
      })
    
    actions_sum, actions_max, actions_min = 0,0,-1
    @completed_actions.each do |r|
      actions_sum += (r.completed_at - r.created_at)
      actions_max = (r.completed_at - r.created_at) if (r.completed_at - r.created_at) > actions_max

      actions_min = (r.completed_at - r.created_at) if actions_min == -1
      actions_min = (r.completed_at - r.created_at) if (r.completed_at - r.created_at) < actions_min
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
    @sum_actions_done_last30days = @actions.count(:all, {
        :conditions => ["completed_at > ? AND NOT completed_at IS NULL", @cut_off_month] 
      })
    @sum_actions_created_last30days = @actions.count(:all, {
        :conditions => ["created_at > ?", @cut_off_month]
      })
    
    # get count of actions done in the past 12 months.
    @sum_actions_done_last12months = @actions.count(:all, {
        :conditions => ["completed_at > ? AND NOT completed_at IS null", @cut_off_year]
      })
    @sum_actions_created_last12months = @actions.count(:all, {
        :conditions => ["created_at > ?", @cut_off_year] 
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
    @projects_and_actions_last30days = @projects.find_by_sql([
        "SELECT p.name, count(*) AS count "+
          "FROM todos t, projects p "+
          "WHERE t.project_id = p.id AND "+
          "      (t.created_at > ? OR t.completed_at > ?) "+
          "AND p.user_id=? "+
          "GROUP BY p.id "+
          "ORDER BY count DESC " +
          "LIMIT 10", @cut_off_month, @cut_off_month, @user.id]
    )
    
    # get the first 10 projects and their running time (creation date versus
    # now())
    @projects_and_runtime_sql = @projects.find_by_sql(
      "SELECT name, created_at "+
        "FROM projects "+
        "WHERE state='active' "+
        "AND user_id="+@user.id.to_s+" "+
        "ORDER BY created_at ASC "+
        "LIMIT 10"
    )

    i=0
    @projects_and_runtime = Array.new(10, ["n/a", "n/a"])
    @projects_and_runtime_sql.each do |r|
      days = (@today - r.created_at) / @seconds_per_day
      # add one so that a project that you just create returns 1 day
      @projects_and_runtime[i]=[r.name, days.to_i+1]
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
    query << " FROM taggings, tags"
    query << " WHERE tags.id = tag_id"
    query << " AND taggings.user_id="+@user.id.to_s+" "
    query << " AND taggings.taggable_type='Todo' "
    query << " GROUP BY tag_id"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
    @tags_for_cloud = Tag.find_by_sql(query).sort_by { |tag| tag.name.downcase }
        
    max, @tags_min = 0, 0
    @tags_for_cloud.each { |t|
      max = t.count.to_i if t.count.to_i > max
      @tags_min = t.count.to_i if t.count.to_i < @tags_min
    }

    @tags_divisor = ((max - @tags_min) / levels) + 1

    # Get the tag cloud for all tags for actions
    query = "SELECT tags.id, tags.name AS name, count(*) AS count"
    query << " FROM taggings, tags, todos"
    query << " WHERE tags.id = tag_id"
    query << " AND taggings.user_id=? "
    query << " AND taggings.taggable_type='Todo' "
    query << " AND taggings.taggable_id=todos.id "
    query << " AND (todos.created_at > ? OR "
    query << "      todos.completed_at > ?) "
    query << " GROUP BY tag_id"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
    @tags_for_cloud_90days = Tag.find_by_sql(
      [query, @user.id, @cut_off_3months, @cut_off_3months]
    ).sort_by { |tag| tag.name.downcase }

    max_90days, @tags_min_90days = 0, 0
    @tags_for_cloud_90days.each { |t|
      max_90days = t.count.to_i if t.count.to_i > max_90days
      @tags_min_90days = t.count.to_i if t.count.to_i < @tags_min_90days
    }

    @tags_divisor_90days = ((max_90days - @tags_min_90days) / levels) + 1
    
  end
end