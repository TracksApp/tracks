module TodoHelper

  # Counts the number of uncompleted items in the selected context
  #
  def count_items(context)
    count = Todo.find_all("done=0 AND context_id=#{context.id}").length
  end

  def form_remote_tag_todo_notdone( item )
    form_remote_tag( :url => url_for( :controller => "todo", :action => "toggle_check", :id => item.id ),
                      :html => { :id=> "checkbox-notdone-#{item.id}", :class => "inline-form" },
                      :update => "completed",
                      :position => "top",
                      :loading => "Form.disable('checkbox-notdone-#{item.id}');",
                      :complete => "new Effect2.Fade('item-#{item.id}-container', true);"
                   )
  end

  def form_remote_tag_todo_done( item )
    form_remote_tag( :url => url_for( :controller => "todo", :action => "toggle_check", :id => item.id ),
                     :html => { :id=> "checkbox-done-#{item.id}", :class => "inline-form" },
                     :update => "new_actions",
                     :position => "bottom",
                     :loading => "Form.disable('checkbox-done-#{item.id}');",
                     :complete => "Element.toggle('new_actions');new Effect2.Fade('done-item-#{item.id}-container', true);"
                   )
  end

  def form_remote_tag_edit_todo( item )
    form_remote_tag( :url => { :controller => 'todo', :action => 'update_action', :id => item.id },
                    :html => { :id => "form-action-#{item.id}", :class => "inline-form" },
                    :update => "item-#{item.id}-container",
                    :complete => "new Effect.Appear('item-#{item.id}-container');"
                   )
  end

  def link_to_remote_todo_notdone( item )
    str = "Element.toggle('item-#{item.id}','action-#{item.id}-edit-form');"
    str << " new Effect.Appear('action-#{item.id}-edit-form');"
    str << " Form.focusFirstElement('form-action-#{item.id}')"
    link_to_remote( image_tag("blank", :title =>"Delete action", :class=>"delete_item"),
                    :update => "item-#{item.id}-container",
                    :loading => "new Effect2.Fade('item-#{item.id}-container', true)",
                    :url => { :controller => "todo", :action => "destroy_action", :id => item.id },
                    :confirm => "Are you sure that you want to delete the action, \'#{item.description}\'?") + " " +
                    link_to_function(image_tag( "blank", :title => "Edit action", :class => "edit_item"),
                    str ) + " "
  end

  def link_to_remote_todo_done( item )
    link_to_remote( image_tag("blank", :title =>"Delete action", :class=>"delete_item"),
                    :update => "done-item-#{item.id}-container",
                    :loading => "new Effect2.Fade('done-item-#{item.id}-container', true)",
                    :url => { :controller => "todo", :action => "destroy_action", :id => item.id },
                    :confirm => "Are you sure that you want to delete the action \'#{item.description}\'?" ) +
                    image_tag("blank") + " "
  end

  def toggle_show_notes( item )
    str = "<a href=\"javascript:Element.toggle('"
    str << item.id.to_s
    str << "')\" class=\"show_notes\" title=\"Show notes\">"
    str << image_tag( "blank", :width=>"16", :height=>"16", :border=>"0" ) + "</a>"
    m_notes = markdown( item.notes )
    str << "<div class=\"notes\" id=\"" + item.id.to_s + "\" style=\"display:none\">"
    str << m_notes + "</div>"
    str
  end
end
