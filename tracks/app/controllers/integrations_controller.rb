class IntegrationsController < ApplicationController

  def index
    @page_title = 'TRACKS::Integrations'
  end
  
  def get_quicksilver_applescript
    context = current_user.contexts.find params[:context_id]
    render :partial => 'quicksilver_applescript', :locals => { :context => context }
  end

  def get_applescript1
    context = current_user.contexts.find params[:context_id]
    render :partial => 'applescript1', :locals => { :context => context }
  end

  def get_applescript2
    context = current_user.contexts.find params[:context_id]
    render :partial => 'applescript2', :locals => { :context => context }
  end
end
