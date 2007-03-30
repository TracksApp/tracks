class FeedlistController < ApplicationController

  helper :feedlist

  def index
    @page_title = 'TRACKS::Feeds'
    init_data_for_sidebar
    render :layout => 'standard'
  end

end
