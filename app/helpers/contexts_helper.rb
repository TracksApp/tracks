module ContextsHelper

  def show_context_name(context)
    if source_view_is :context
      content_tag(:span, :id => "context_name"){context.name}
    else
      link_to_context( context )
    end
  end

  def link_to_delete_context(context, descriptor = sanitize(context.name))
    link_to_delete(:context, context, descriptor)
  end

  def link_to_edit_context (context, descriptor = sanitize(context.name))
    link_to_edit(:context, context, descriptor)
  end

  def context_summary(context, undone_todo_count)
    content_tag(:p, "#{undone_todo_count}. Context is #{context.hidden? ? 'Hidden' : 'Active'}.".html_safe)
  end

end
