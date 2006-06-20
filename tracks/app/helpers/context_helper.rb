module ContextHelper

  def get_listing_sortable_options
    {
      :tag => 'div',
      :handle => 'handle',
      :complete => visual_effect(:highlight, 'list-contexts'),
      :url => {:controller => 'context', :action => 'order'}
    }
  end

end
