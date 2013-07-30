class SessionBackdoorController < ::ApplicationController
  skip_before_filter :login_required

  def create
    session['user_id'] = params[:user_id]
    user = User.find(params[:user_id])
    set_current_user(user)
    user.remember_me
    cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
    redirect_to root_path
  end

  def expire_session
    current_user.forget_me if logged_in?
    cookies.delete :auth_token
    session['user_id'] = nil
    reset_session
    session['expiry_time'] = Time.now

    respond_to do |format|
      format.html { render :text => "Session expired for test purposes"}
      format.js   { render :text => "" }
    end
  end
end

module TracksLoginHelper
  begin
    _routes = Rails.application.routes
    _routes.disable_clear_and_finalize = true
    _routes.clear!
    Rails.application.routes_reloader.paths.each{ |path| load(path) }
    _routes.draw do
      # here you can add any route you want
      get "/test_login_backdoor", to: "session_backdoor#create"
      get "login/expire_session", to: "session_backdoor#expire_session"
    end
    ActiveSupport.on_load(:action_controller) { _routes.finalize! }
  ensure
    _routes.disable_clear_and_finalize = false
  end

  def request_signin_as(user)
    visit "/test_login_backdoor?user_id=#{user.id}"
  end

  def signin_as(user)
    session[:user_id] = user.id
    @current_user = user
  end

end
