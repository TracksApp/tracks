module ContextsHelper

  def get_listing_sortable_options
    {
      :tag => 'div',
      :handle => 'handle',
      :complete => visual_effect(:highlight, 'list-contexts'),
      :url => order_contexts_path
    }
  end

end
