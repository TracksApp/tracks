class IntegrationsController < ApplicationController
  require 'mail'
  
  skip_before_filter :login_required, :only => [:cloudmailin, :search_plugin, :google_gadget]
  
  def index
    @page_title = 'TRACKS::Integrations'
  end
  
  def rest_api
    @page_title = 'TRACKS::REST API Documentation'
  end
    
  def get_quicksilver_applescript
    get_applescript('quicksilver_applescript')
  end

  def get_applescript1
    get_applescript('applescript1')
  end

  def get_applescript2
    get_applescript('applescript2')
  end

  def search_plugin
    @icon_data = [File.open(File.join(Rails.root, 'app', 'assets', 'images', 'done.png')).read].
      pack('m').gsub(/\n/, '')
  end

  def google_gadget
    render :layout => false, :content_type => Mime::XML
  end
  
  def cloudmailin
    if !verify_cloudmailin_signature
      render :text => "Message signature verification failed.", :status => 403
      return false
    end
    
    if process_message(params[:message])
      render :text => 'success', :status => 200
    else
      render :text => "No user found or other error", :status => 404
    end
  end
  
  private

  def process_message(message)
    MessageGateway::receive(Mail.new(message))
  end

  def verify_cloudmailin_signature
    provided = request.request_parameters.delete(:signature)
    signature = Digest::MD5.hexdigest(request.request_parameters.sort{|a,b| a[0].to_s <=> b[0].to_s}.map{|k,v| v}.join + SITE_CONFIG['cloudmailin'])
    return provided == signature
  end
  
  def get_applescript(partial_name)
    context = current_user.contexts.find params[:context_id]
    render :partial => partial_name, :locals => { :context => context }
  end
  
end
