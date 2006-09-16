class UserController < ApplicationController
  layout 'standard'
  prepend_before_filter :login_required
  
  def index
    render_text "This will be our jumping-off point for managing user functions!"
  end
  
  def admin
    render_text "You'll only be allowed to go here if you're an administrator."
  end
  
  verify  :method => :post,
          :only => %w( create_user ),
          :render => { :text => '403 Forbidden: Only POST requests on this resource are allowed.',
                      :status => 403 }
  
  # Example usage: curl -H 'Accept: application/xml' -H 'Content-Type: application/xml'
  #               -u admin:up2n0g00d
  #               -d '<request><login>username</login><password>abc123</password></request>'
  #               http://our.tracks.host/user/create
  #
  def create
     admin = User.find_admin
     #render_text "user is " + session["user_id"].to_s + " and admin is " + a.id.to_s
      unless session["user_id"].to_i == admin.id.to_i
        access_denied
        return
      end
      unless request.content_type == "application/xml"
        render_failure "Content Type must be application/xml."
        return
      end
      unless check_create_user_params
        render_failure "Expected post format is xml like so: <request><login>username</login><password>abc123</password></request>."
        return
      end
      user = User.new(params[:request])
      user.password_confirmation = params[:request][:password]
      unless user.valid?
        render_failure user.errors.full_messages.join(', ')
        return
      end
      if user.save
        render :text => "User created.", :status => 200
      else
        render_failure "Failed to create user."
      end
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
  
  def refresh_token
    @user.crypt_word
    @user.save
    redirect_to :controller => 'user', :action => 'preferences'
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

  private
    
  def check_create_user_params
    return false unless params.has_key?(:request)
    return false unless params[:request].has_key?(:login)
    return false if params[:request][:login].empty?
    return false unless params[:request].has_key?(:password)
    return false if params[:request][:password].empty?
    return true
  end
  
  
end