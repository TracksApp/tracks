module ContextsHelper

def get_listing_sortable_options
  {
    :tag => 'div',
    :handle => 'handle',
    :complete => visual_effect(:highlight, 'list-contexts'),
    :url => order_contexts_path
  }
end

def link_to_delete_context(context, descriptor = sanitize(context.name))
  link_to(
  descriptor,
  context_path(context, :format => 'js'),
  {
    :id => "delete_context_#{context.id}",
    :class => "delete_context_button",
    :x_confirm_message => t('contexts.delete_context_confirmation', :name => context.name),
    :title => t('contexts.delete_context_title')
  }
  )
end

def summary(context, undone_todo_count)
  content_tag(:p, "#{undone_todo_count}. Context is #{context.hidden? ? 'Hidden' : 'Active'}.")
end


end
