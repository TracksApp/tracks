module ProjectsHelper

  def get_listing_sortable_options(list_container_id)
    {
      :tag => 'div',
      :handle => 'handle',
      :complete => visual_effect(:highlight, list_container_id),
      :url => order_projects_path
    }
  end

end
