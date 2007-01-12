module ProjectsHelper

def get_listing_sortable_options
  {
    :tag => 'div',
    :handle => 'handle',
    :complete => visual_effect(:highlight, 'list-projects'),
    :url => order_projects_path
  }
end

end
