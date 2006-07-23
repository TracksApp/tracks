class UserController < ApplicationController
  layout 'standard'
  before_filter :login_required
  
  def index
    render_text "This will be our jumping-off point for managing user functions!"
  end
  
  def admin
    render_text "You'll only be allowed to go here if you're an administrator."
  end
  
  def preferences
    @page_title = "TRACKS::Preferences"
    @prefs = @user.preferences
  end

  def edit_preferences
    @page_title = "TRACKS::Edit Preferences"
    @prefs = @user.preferences
    
    render :action => "preference_edit_form", :object => @prefs
  end
  
  def update_preferences
    @user.preferences = { "date_format" => "#{params['prefs']['date_format']}",
                          "week_starts" => "#{params['prefs']['week_starts']}",
                          "no_completed" => "#{params['prefs']['no_completed']}",
                          "staleness_starts" => "#{params['prefs']['staleness_starts']}",
                          "due_style" => "#{params['prefs']['due_style']}",
                          "admin_email" => "#{params['prefs']['admin_email']}",
                          "refresh" => "#{params['prefs']['refresh']}"
                          }
    if @user.save
      redirect_to :action => 'preferences'
    else
      render :action => 'edit_preferences'
    end
  end
  
  def change_password
    @page_title = "TRACKS::Change password"
  end
  
  def update_password
    if do_change_password_for(@user)
      redirect_to :controller => 'user', :action => 'preferences'
    else
      redirect_to :controller => 'user', :action => 'change_password'
    end
  end
  
  protected
  
  def do_change_password_for(user)
    user.change_password(params[:updateuser][:password], params[:updateuser][:password_confirmation])
    if user.save
      flash["notice"] = "Password updated."
      return true
    else
      flash["warning"] = 'There was a problem saving the password. Please retry.'
      return false
    end
  end
  
end