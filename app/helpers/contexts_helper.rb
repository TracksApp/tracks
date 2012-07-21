module ContextsHelper
  
  def link_to_delete_context(context, descriptor = sanitize(context.name))
    link_to(descriptor,
      context_path(context, :format => 'js'),
      {
        :id => "delete_context_#{context.id}",
        :class => "delete_context_button icon",
        :x_confirm_message => t('contexts.delete_context_confirmation', :name => context.name),
        :title => t('contexts.delete_context_title')
      })
  end

  def link_to_edit_context (context, descriptor = sanitize(context.name))
    link_to(descriptor, edit_context_path(context),
      {
        :id => "link_edit_#{dom_id(context)}",
        :class => "context_edit_settings icon"
      })
  end

  def context_summary(context, undone_todo_count)
    content_tag(:p, "#{undone_todo_count}. Context is #{context.hidden? ? 'Hidden' : 'Active'}.".html_safe)
  end

end
