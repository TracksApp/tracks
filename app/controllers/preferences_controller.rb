class PreferencesController < ApplicationController

  def index
    @page_title = t('preferences.page_title')
    @prefs = current_user.prefs
    @user = current_user
  end

  def update
    @prefs = current_user.prefs
    @user = current_user
    user_updated = current_user.update_attributes(user_params)
    prefs_updated = current_user.preference.update_attributes(prefs_params)
    if (user_updated && prefs_updated)
      if params['user']['password'].present? # password updated?
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
    render :text => l(Date.current, :format => format)
  end

private

  def prefs_params
    params.require(:prefs).permit(
      :date_format, :week_starts, :show_number_completed,
      :show_completed_projects_in_sidebar, :show_hidden_contexts_in_sidebar,
      :staleness_starts, :due_style, :locale, :title_date_format, :time_zone,
      :show_hidden_projects_in_sidebar, :show_project_on_todo_done,
      :review_period, :refresh, :verbose_action_descriptors,
      :mobile_todos_per_page, :sms_email, :sms_context_id)
  end

  def user_params
    params.require(:user).permit(:login, :first_name, :last_name, :password_confirmation, :password, :auth_type, :open_id_url)
  end

  # Display notification if preferences are successful updated
  def preference_updated
    notify :notice, t('preferences.updated')
    redirect_to :action => 'index'
  end

end
