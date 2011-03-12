class LoginController < ApplicationController
  
  layout 'login'
  filter_parameter_logging :user_password 
  skip_before_filter :set_session_expiration
  skip_before_filter :login_required
  before_filter :login_optional
  before_filter :get_current_user

  protect_from_forgery :except => :check_expiry

  if ( SITE_CONFIG['authentication_schemes'].include? 'cas')
    # This will allow the user to view the index page without authentication
    # but will process CAS authentication data if the user already
    # has an SSO session open.
    if defined? CASClient
      # Only require sub-library if gem is installed and loaded
      require 'casclient/frameworks/rails/filter'
      before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :login_cas

      # This requires the user to be authenticated for viewing all other pages.
      before_filter CASClient::Frameworks::Rails::Filter, :only => [:login_cas ]
    end
  end

  def login
    if cas_enabled?
      @username = session[:cas_user]
      @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
    end
    if openid_enabled? && using_open_id?
      login_openid
    elsif cas_enabled? && session[:cas_user]
      login_cas
    else
      @page_title = "TRACKS::Login"
      cookies[:preferred_auth] = prefered_auth? unless cookies[:preferred_auth]
      case request.method
      when :post
        if @user = User.authenticate(params['user_login'], params['user_password'])
          session['user_id'] = @user.id
          # If checkbox on login page checked, we don't expire the session after 1 hour
          # of inactivity and we remember this user for future browser sessions
          session['noexpiry'] = params['user_noexpiry']
          msg = (should_expire_sessions?) ? "will expire after 1 hour of inactivity." : "will not expire."
          notify :notice, "Login successful: session #{msg}"
          cookies[:tracks_login] = { :value => @user.login, :expires => Time.now + 1.year, :secure => SITE_CONFIG['secure_cookies'] }
          unless should_expire_sessions?
            @user.remember_me
            cookies[:auth_token] = { :value => @user.remember_token , :expires => @user.remember_token_expires_at, :secure => SITE_CONFIG['secure_cookies'] }
          end
          redirect_back_or_home
          return
        else
          @login = params['user_login']
          notify :warning, t('login.unsuccessful')
        end
      when :get
        if User.no_users_yet?
          redirect_to signup_path
          return
        end
      end
      respond_to do |format|
        format.html
        format.m   { render :action => 'login_mobile.html.erb', :layout => 'mobile' }
      end
    end
  end
  
  def logout
    @user.forget_me if logged_in?
    cookies.delete :auth_token
    session['user_id'] = nil
    if ( SITE_CONFIG['authentication_schemes'].include? 'cas')  && session[:cas_user]
      CASClient::Frameworks::Rails::Filter.logout(self)
    else
      reset_session
      notify :notice, t('login.logged_out')
      redirect_to_login
    end
  end

  def expire_session
    # this is a hack to enable cucumber to expire a session by calling this
    # method. The method will be unavailable for production environment
    unless Rails.env.production?
      session['expiry_time'] = Time.now
      respond_to do |format|
        format.html { render :text => "Session expired for test purposes"}
        format.js { render :text => "" }
      end
    else
      respond_to do |format|
        format.html { render :text => "Not available for production use"}
        format.js { render :text => "" }
      end
    end
  end
  
  def check_expiry
    # Gets called by periodically_call_remote to check whether
    # the session has timed out yet
    unless session == nil
      if session
        return unless should_expire_sessions?
        # Get expiry time (allow ten seconds window for the case where we have none)
        expiry_time = session['expiry_time'] || Time.now + 10
        time_left = expiry_time - Time.now
        @session_expired = ( time_left < (10*60) ) # Session will time out before the next check
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def login_cas
    # If checkbox on login page checked, we don't expire the session after 1 hour
    # of inactivity and we remember this user for future browser sessions

    session['noexpiry'] ||= params['user_noexpiry']
    if session[:cas_user]
      if @user = User.find_by_login(session[:cas_user])
        session['user_id'] = @user.id
        msg = (should_expire_sessions?) ? t('login.session_will_expire', :hours => 1) : t('login.session_will_not_expire')
        notify :notice, (t('login.successful_with_session_info') + msg)
        cookies[:tracks_login] = { :value => @user.login, :expires => Time.now + 1.year, :secure => SITE_CONFIG['secure_cookies'] }
        unless should_expire_sessions?
          @user.remember_me
          cookies[:auth_token] = { :value => @user.remember_token, :expires => @user.remember_token_expires_at, :secure => SITE_CONFIG['secure_cookies'] }
        end
      else
        notify :warning, t('login.cas_username_not_found', :username => session[:cas_user])
        redirect_to signup_url ; return
      end
    else
      notify :warning, result.message
    end
    redirect_back_or_home

  end
  
  private
      
  def redirect_to_login
    respond_to do |format|
      format.html { redirect_to login_path }
      format.m { redirect_to login_path(:format => 'm') }
    end
  end
  
  def should_expire_sessions?
    session['noexpiry'] != "on"
  end
  
  protected
  
  def login_openid
    # If checkbox on login page checked, we don't expire the session after 1 hour
    # of inactivity and we remember this user for future browser sessions
    session['noexpiry'] ||= params['user_noexpiry']
    authenticate_with_open_id do |result, identity_url|
      if result.successful?
        if @user = User.find_by_open_id_url(identity_url)
          session['user_id'] = @user.id
          msg = (should_expire_sessions?) ? t('login.session_will_expire', :hours => 1) : t('login.session_will_not_expire')
          notify :notice, (t('login.successful_with_session_info') + msg)
          cookies[:tracks_login] = { :value => @user.login, :expires => Time.now + 1.year, :secure => SITE_CONFIG['secure_cookies'] }
          unless should_expire_sessions?
            @user.remember_me
            cookies[:auth_token] = { :value => @user.remember_token , :expires => @user.remember_token_expires_at, :secure => SITE_CONFIG['secure_cookies'] }
          end
          redirect_back_or_home
        else
          notify :warning, t('login.openid_identity_url_not_found', :identity_url => identity_url)
        end
      else
        notify :warning, result.message
      end
    end
  end


end
