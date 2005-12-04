module TodoHelper

  # Counts the number of uncompleted items in the specified context
  #
  def count_items(context)
    count = Todo.find_all("done=0 AND context_id=#{context.id}").length
  end

  def form_remote_tag_toggle_todo( item )
    target_div = item.done? ? "new_actions" : "completed"
    target_position = item.done? ? "bottom" : "top"
    form_id = "checkbox-#{item.id}-form"
    item_container_id = "item-#{item.id}-container"

    loading_javascript = "Form.disable('#{form_id}');"
    if item.done?
      loading_javascript << visual_effect(:appear, "new_actions", :duration => 0.4)
    end

    success_javascript = " $('#{item_container_id}').setAttribute('id','#{item_container_id}-fading');"
    success_javascript << visual_effect(  :fade, "#{item_container_id}-fading",
                                          {
                                            :duration => 0.4,
                                            :afterFinish => "function(effect) { Element.remove('#{item_container_id}-fading'); }"
                                          })

    form_remote_tag( :url => url_for( :controller => "todo", :action => "toggle_check", :id => item.id ),
                     :html => { :id=> "#{form_id}", :class => "inline-form item-checkmark-form" },
                     :update => target_div,
                     :position => target_position,
                     :loading => loading_javascript,
                     :success => success_javascript,
                     :complete => visual_effect( :highlight, item_container_id))
  end

  def form_remote_tag_edit_todo( item )
    form_remote_tag( :url => { :controller => 'todo', :action => 'update_action', :id => item.id },
                    :html => { :id => "form-action-#{item.id}", :class => "inline-form" },
                    :update => "item-#{item.id}-container",
                    :complete => visual_effect(:appear, "item-#{item.id}-container")
                   )
  end
  
  def link_to_remote_todo( item )
    str = link_to_remote( image_tag("blank", :title =>"Delete action", :class=>"delete_item"),
                      {
                        :update => "item-#{item.id}-container",
                        :loading => visual_effect(:fade, "item-#{item.id}-container"),
                        :url => { :controller => "todo", :action => "destroy_action", :id => item.id },
                        :confirm => "Are you sure that you want to delete the action, \'#{item.description}\'?"
                        },
                        {
                          :class => "icon"
                        }) + "\n"
    if !item.done?
      str << link_to_remote( image_tag("blank", :title =>"Edit action", :class=>"edit_item", :id=>"action-#{item.id}-edit-icon"),
                      {
                        :update => "form-action-#{item.id}",
                        :loading => visual_effect(:pulsate, "action-#{item.id}-edit-icon"),
                        :url => { :controller => "todo", :action => "edit_action", :id => item.id },
                        :success => "Element.toggle('item-#{item.id}','action-#{item.id}-edit-form'); new Effect.Appear('action-#{item.id}-edit-form', { duration: .2 });  Form.focusFirstElement('form-action-#{item.id}')"
                      },
                      {
                        :class => "icon"
                      })
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
    if item.due || item.done
      return ""
    elsif item.created_at < (ApplicationController::STALENESS_STARTS*3).days.ago
      return " stale_l3"
    elsif item.created_at < (ApplicationController::STALENESS_STARTS*2).days.ago
      return " stale_l2"
    elsif item.created_at < (ApplicationController::STALENESS_STARTS).days.ago
      return " stale_l1"
    else
      return ""
    end
  end

  # Check due date in comparison to today's date
  # Flag up date appropriately with a 'traffic light' colour code
  #
  def due_date(due)
    if due == nil
      return ""
    end

    @now = Date.today
    @days = due-@now
       
    case @days
      # overdue or due very soon! sound the alarm!
      when -365..-1
        "<a title='" + format_date(due) + "'><span class=\"red\">Overdue by " + (@days * -1).to_s + " days</span></a> "
      when 0
           "<a title='" + format_date(due) + "'><span class=\"amber\">Due Today</span></a> "
      when 1
           "<a title='" + format_date(due) + "'><span class=\"amber\">Due Tomorrow</span></a> "
      # due 2-7 days away
      when 2..7
           "<a title='" + format_date(due) + "'><span class=\"orange\">Due in " + @days.to_s + " days</span></a> "
      # more than a week away - relax
      else
        "<a title='" + format_date(due) + "'><span class=\"green\">Due in " + @days.to_s + " days</span></a> "
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
    str = "Calendar.setup({ ifFormat:\"#{ApplicationController::DATE_FORMAT}\""
    str << ",firstDay:#{ApplicationController::WEEK_STARTS_ON},showOthers:true,range:[2004, 2010]"
    str << ",step:1,inputField:\"" + input_field + "\",cache:true,align:\"TR\" })"
    javascript_tag str
  end
  
end
