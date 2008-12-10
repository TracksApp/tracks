class IntegrationsController < ApplicationController

  skip_before_filter :login_required, :only => :search_plugin

  def index
    @page_title = 'TRACKS::Integrations'
  end
  
  def rest_api
    @page_title = 'TRACKS::REST API Documentation'
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

  def search_plugin
	@icon_data = [File.open(RAILS_ROOT + '/public/images/done.png').read].
	  pack('m').gsub(/\n/, '')

	render :layout => false
  end

end
