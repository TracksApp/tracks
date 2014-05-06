require 'mail'

class Integrations::CloudmailinController < ApplicationController
  skip_before_filter :login_required
  
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

end
