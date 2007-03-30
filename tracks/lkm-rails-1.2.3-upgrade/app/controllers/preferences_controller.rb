class PreferencesController < ApplicationController
    
  def index
    @page_title = "TRACKS::Preferences"
    @prefs = @user.preference
  end

  def edit
    @page_title = "TRACKS::Edit Preferences"
    @prefs = @user.preference
    
    render :object => @prefs
  end
  
  def update
    user_success = @user.update_attributes(params['user'])
    prefs_success = @user.preference.update_attributes(params['prefs'])
    if user_success && prefs_success
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
end