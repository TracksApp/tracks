class PreferencesController < ApplicationController

  def index
    @page_title = t('preferences.page_title')
    @prefs = current_user.prefs
    @user = current_user
  end

  def update
    @prefs = current_user.prefs
    @user = current_user
    user_updated = current_user.update_attributes(params['user'])
    prefs_updated = current_user.preference.update_attributes(params['prefs'])
    if (user_updated && prefs_updated)
      if !params['user']['password'].blank? # password updated?
        logout_user t('preferences.password_changed')
      else
        preference_updated
      end
    else
      msg = "Preferences could not be updated: "
      msg += "User model errors; " unless user_updated
      msg += "Prefs model errors; " unless prefs_updated
      notify :warning, msg
      render 'index'
    end
  end

  def render_date_format
    format = params[:date_format]
    render :text => l(Date.today, :format => format)
  end

private

  # Display notification if preferences are successful updated
  def preference_updated
    notify :notice, t('preferences.updated')
    redirect_to :action => 'index'
  end
  
end
