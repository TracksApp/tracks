module ProjectHelper

def get_listing_sortable_options
  {
    :tag => 'div',
    :handle => 'handle',
    :complete => visual_effect(:highlight, 'list-projects'),
    :url => {:controller => 'project', :action => 'order'}
  }
end

end
