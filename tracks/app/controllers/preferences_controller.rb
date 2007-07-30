class PreferencesController < ApplicationController
    
  def index
    @page_title = "TRACKS::Preferences"
    @prefs = prefs
  end

  def edit
    @page_title = "TRACKS::Edit Preferences"
    render :object => prefs
  end
  
  def update
    user_updated = current_user.update_attributes(params['user'])
    prefs_updated = current_user.preference.update_attributes(params['prefs'])
    if user_updated && prefs_updated
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
end