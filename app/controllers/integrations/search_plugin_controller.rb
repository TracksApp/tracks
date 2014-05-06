class Integrations::SearchPluginController < ApplicationController
  skip_before_filter :login_required

  def search_plugin
    @icon_data = [File.open(File.join(Rails.root, 'app', 'assets', 'images', 'done.png')).read].
      pack('m').gsub(/\n/, '')
  end
end
