class IntegrationsController < ApplicationController
  require 'mail'
  
  skip_before_filter :login_required, :only => [:cloudmailin, :search_plugin, :google_gadget]
  before_filter :verify_cloudmailin_signature, :only => [:cloudmailin]

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

  def google_gadget
    render :layout => false, :content_type => Mime::XML
  end
  
  def cloudmailin
    message = Mail.new(params[:message])
    
    # debug
    #puts message.from.addresses.first
    
    # find user
    user = User.find(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", message.from.addresses.first])
    if user.nil?
      render :text => "No user found", :status => 404
      return false
    end

    context = user.prefs.sms_context
    # prepare body
    if message.body.multipart?
      #body = message.body.parts[0].to_s
      body = message.body.preamble
    else
      body = message.body.to_s
    end
    
    # parse mail
    if message.subject.to_s.empty?
      description = body
      notes = nil
    else
      description = message.subject.decoded.to_s
      notes = body
    end
    
    todo = Todo.from_rich_message(user, context.id, description, notes)
    todo.save!
    render :text => 'success', :status => 200
  end

private

  def verify_cloudmailin_signature
    provided = request.request_parameters.delete(:signature)
    signature = Digest::MD5.hexdigest(request.request_parameters.sort.map{|k,v| v}.join + SITE_CONFIG['cloudmailin'])

    if provided != signature
      render :text => "Message signature fail #{provided} != #{signature}", :status => 403
      return false 
    end
  end
end
