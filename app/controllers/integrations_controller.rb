class IntegrationsController < ApplicationController
  require 'mail'

  skip_before_filter :login_required, :only => [:cloudmailin, :search_plugin]
  skip_before_filter :verify_authenticity_token, only: [:cloudmailin]

  def index
    @page_title = 'TRACKS::Integrations'
  end

  def rest_api
    @page_title = 'TRACKS::REST API Documentation'
  end

  def search_plugin
    @icon_data = [File.open(File.join(Rails.root, 'app', 'assets', 'images', 'done.png')).read].
      pack('m').gsub(/\n/, '')
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
    signature = Digest::MD5.hexdigest(flatten_params(request.request_parameters).sort.map{|k,v| v}.join + SITE_CONFIG['cloudmailin'])
    return provided == signature
  end

  def flatten_params(params, title = nil, result = {})
    params.each do |key, value|
      if value.kind_of?(Hash)
        key_name = title ? "#{title}[#{key}]" : key
        flatten_params(value, key_name, result)
      else
        key_name = title ? "#{title}[#{key}]" : key
        result[key_name] = value
      end
    end

    return result
  end

end

