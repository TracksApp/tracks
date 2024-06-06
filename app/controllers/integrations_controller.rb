class IntegrationsController < ApplicationController
  require 'mail'

  skip_before_action :login_required, :only => [:search_plugin]

  def index
    @page_title = 'TRACKS::Integrations'
  end

  def rest_api
    @page_title = 'TRACKS::REST API Documentation'
  end

  def help
    @page_title = 'TRACKS::Help'
  end

  def search_plugin
    @icon_data = [File.open(File.join(Rails.root, 'app', 'assets', 'images', 'done.png')).read]
      .pack('m').gsub(/\n/, '')
  end

  private

  def flatten_params(params, title = nil, result = {})
    params.each do |key, value|
      if value.is_a? Hash
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
