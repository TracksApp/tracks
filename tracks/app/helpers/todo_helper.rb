module TodoHelper

  require 'user_controller'
  # Counts the number of uncompleted items in the specified context
  #
  def count_items(context)
    count = Todo.find_all("done=0 AND context_id=#{context.id}").length
  end

  def form_remote_tag_edit_todo( item, type )
    (type == "deferred") ? controller_name = 'deferred' : controller_name = 'todo'
    form_remote_tag( :url => { :controller => controller_name, :action => 'update', :id => item.id },
                    :html => { :id => "form-action-#{item.id}", :class => "inline-form" }
                   )
  end
  
  def link_to_remote_todo( item, options = {})
    (options[:type] == "deferred") ? controller_name = 'deferred' : controller_name = 'todo'
    url_options = { :controller => controller_name, :action => 'destroy', :id => item.id, :_source_view => @source_view }
    
    str = link_to_remote( image_tag_for_delete,
                          { :url => url_options, :confirm => "Are you sure that you want to delete the action, \'#{item.description}\'?" },
                          { :class => "icon" }
                        ) + "\n"
    if !item.done?
      url_options[:action] = 'edit'
      str << link_to_remote( image_tag_for_edit(item),
                             { :url => url_options, :loading => visual_effect(:pulsate, "action-#{item.id}-edit-icon") },
                             { :class => "icon" }
                           )
    else
      str << '<a class="icon">' + image_tag("blank") + "</a> "
    end
    str
  end
  
  # Uses the 'staleness_starts' value from settings.yml (in days) to colour
  # the background of the action appropriately according to the age
  # of the creation date:
  # * l1: created more than 1 x staleness_starts, but < 2 x staleness_starts
  # * l2: created more than 2 x staleness_starts, but < 3 x staleness_starts
  # * l3: created more than 3 x staleness_starts
  #
  def staleness_class(item)
    if item.due || item.done?
      return ""
    elsif item.created_at < (@user.preference.staleness_starts * 3).days.ago
      return " stale_l3"
    elsif item.created_at < (@user.preference.staleness_starts * 2).days.ago
      return " stale_l2"
    elsif item.created_at < (@user.preference.staleness_starts).days.ago
      return " stale_l1"
    else
      return ""
    end
  end

  # Check show_from date in comparison to today's date
  # Flag up date appropriately with a 'traffic light' colour code
  #
  def show_date(due)
    if due == nil
      return ""
    end

    @now = Date.today
    @days = due-@now
       
    case @days
      # overdue or due very soon! sound the alarm!
      when -1000..-1
        "<a title='" + format_date(due) + "'><span class=\"red\">Shown on " + (@days * -1).to_s + " days</span></a> "
      when 0
           "<a title='" + format_date(due) + "'><span class=\"amber\">Show Today</span></a> "
      when 1
           "<a title='" + format_date(due) + "'><span class=\"amber\">Show Tomorrow</span></a> "
      # due 2-7 days away
      when 2..7
      if @user.preference.due_style == 1
        "<a title='" + format_date(due) + "'><span class=\"orange\">Show on " + due.strftime("%A") + "</span></a> "
      else
        "<a title='" + format_date(due) + "'><span class=\"orange\">Show in " + @days.to_s + " days</span></a> "
      end
      # more than a week away - relax
      else
        "<a title='" + format_date(due) + "'><span class=\"green\">Show in " + @days.to_s + " days</span></a> "
    end
  end

  def toggle_show_notes( item )
    str = "<a href=\"javascript:Element.toggle('"
    str << item.id.to_s
    str << "')\" class=\"show_notes\" title=\"Show notes\">"
    str << image_tag( "blank", :width=>"16", :height=>"16", :border=>"0" ) + "</a>"
    m_notes = markdown( item.notes )
    str << "\n<div class=\"notes\" id=\"" + item.id.to_s + "\" style=\"display:none\">"
    str << m_notes + "</div>"
    str
  end
  
  def calendar_setup( input_field )
    date_format = @user.preference.date_format
    week_starts = @user.preference.week_starts
    str = "Calendar.setup({ ifFormat:\"#{date_format}\""
    str << ",firstDay:#{week_starts},showOthers:true,range:[2004, 2010]"
    str << ",step:1,inputField:\"" + input_field + "\",cache:true,align:\"TR\" })\n"
    javascript_tag str
  end
  
  private
  
  def image_tag_for_delete
    image_tag("blank", :title =>"Delete action", :class=>"delete_item")
  end
  
  def image_tag_for_edit(item)
    image_tag("blank", :title =>"Edit action", :class=>"edit_item", :id=>"action-#{item.id}-edit-icon")
  end
  
end
