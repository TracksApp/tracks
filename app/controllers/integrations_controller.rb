class IntegrationsController < ApplicationController
  def index
    @page_title = 'TRACKS::Integrations'
  end
  
  def api_docs
    @page_title = 'TRACKS::REST API Documentation'
  end
end
