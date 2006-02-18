class UserController < ApplicationController
  layout 'standard'
  
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
    @user.preferences = { "date_format" => "#{@params['prefs']['date_format']}",
                          "week_starts" => "#{@params['prefs']['week_starts']}",
                          "no_completed" => "#{@params['prefs']['no_completed']}",
                          "staleness_starts" => "#{@params['prefs']['staleness_starts']}",
                          "due_style" => "#{@params['prefs']['due_style']}",
                          "admin_email" => "#{@params['prefs']['admin_email']}"
                          }
    if @user.save
      redirect_to :action => 'preferences'
    else
      render :action => 'edit_preferences'
    end
  end
  
end