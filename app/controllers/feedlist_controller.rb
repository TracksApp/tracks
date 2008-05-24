class FeedlistController < ApplicationController

  helper :feedlist

  def index
    @page_title = 'TRACKS::Feeds'
    init_data_for_sidebar unless mobile?
    respond_to do |format|
      format.html { render :layout => 'standard' }
      format.m { 
        # @projects = @projects || current_user.projects.find(:all, :include => [:default_context ])
        # @contexts = @contexts || current_user.contexts
        render :action => 'mobile_index' 
      }
    end
  end

end
