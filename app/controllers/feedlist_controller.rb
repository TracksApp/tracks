class FeedlistController < ApplicationController

  helper :feedlist

  def index
    @page_title = 'TRACKS::Feeds'
    init_data_for_sidebar unless mobile?
    
    @active_projects = @projects.select{ |p| p.active? }
    @hidden_projects = @projects.select{ |p| p.hidden? }
    @completed_projects = @projects.select{ |p| p.completed? }
    
    @active_contexts = @contexts.select{ |c| !c.hidden? }
    @hidden_contexts = @contexts.select{ |c| c.hidden? }
    
    respond_to do |format|
      format.html { render :layout => 'standard' }
      format.m { render :action => 'mobile_index' }
    end
  end
  
  def get_feeds_for_context
    context = current_user.contexts.find params[:context_id]
    render :partial => 'feed_for_context', :locals => { :context => context }
  end

  def get_feeds_for_project
    project = current_user.projects.find params[:project_id]
    render :partial => 'feed_for_project', :locals => { :project => project }
  end

end
