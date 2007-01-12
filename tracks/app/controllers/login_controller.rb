class LoginController < ApplicationController
  
  layout  'login'
  skip_before_filter :set_session_expiration
  skip_before_filter :login_required
  before_filter :get_current_user
  open_id_consumer if Tracks::Config.auth_schemes.include?('open_id')
  
  def login
    @page_title = "TRACKS::Login"
    case request.method
      when :post
        if @user = User.authenticate(params['user_login'], params['user_password'])
          session['user_id'] = @user.id
          # If checkbox on login page checked, we don't expire the session after 1 hour
          # of inactivity
          session['noexpiry'] = params['user_noexpiry']
          msg = (should_expire_sessions?) ? "will expire after 1 hour of inactivity." : "will not expire." 
          notify :notice, "Login successful: session #{msg}"
          cookies[:tracks_login] = { :value => @user.login, :expires => Time.now + 1.year }
          redirect_back_or_default :controller => "todo", :action => "index"
        else
          @login = params['user_login']
          notify :warning, "Login unsuccessful"
        end
      when :get
        if User.no_users_yet?
          redirect_to :action => 'signup'
        end
    end
  end
  
  def begin
    # If the URL was unusable (either because of network conditions,
    # a server error, or that the response returned was not an OpenID
    # identity page), the library will return HTTP_FAILURE or PARSE_ERROR.
    # Let the user know that the URL is unusable.
    case open_id_response.status
      when OpenID::SUCCESS
        # The URL was a valid identity URL. Now we just need to send a redirect
        # to the server using the redirect_url the library created for us.

        # redirect to the server
        redirect_to open_id_response.redirect_url((request.protocol + request.host_with_port + "/"), url_for(:action => 'complete'))
      else
        notify :warning, "Unable to find openid server for <q>#{params[:openid_url]}</q>"
        redirect_to :action => 'login'
    end
  end

  def complete
    case open_id_response.status
      when OpenID::FAILURE
        # In the case of failure, if info is non-nil, it is the
        # URL that we were verifying. We include it in the error
        # message to help the user figure out what happened.
        if open_id_response.identity_url
          msg = "Verification of #{open_id_response.identity_url} failed. "
        else
          msg = "Verification failed. "
        end
        notify :error, open_id_response.msg.to_s + msg

      when OpenID::SUCCESS
        # Success means that the transaction completed without
        # error. If info is nil, it means that the user cancelled
        # the verification.
        @user = User.find_by_open_id_url(open_id_response.identity_url)
        unless (@user.nil?)
          notify :notice, "You have successfully verified #{open_id_response.identity_url} as your identity."
          session['user_id'] = @user.id
          redirect_back_or_default :controller => 'todo', :action => 'index'
        else
          notify :warning, "You have successfully verified #{open_id_response.identity_url} as your identity, but you do not have a Tracks account. Please ask your administrator to sign you up."
        end

      when OpenID::CANCEL
        notify :warning, "Verification cancelled."

      else
        notify :warning, "Unknown response status: #{open_id_response.status}"
    end
    redirect_to :action => 'login' unless performed?
  end

  def signup
    if User.no_users_yet?
      @page_title = "Sign up as the admin user"
      @user = get_new_user
    elsif @user && @user.is_admin?
      @page_title = "Sign up a new user"
      @user = get_new_user
    else # all other situations (i.e. a non-admin is logged in, or no one is logged in, but we have some users)
      @page_title = "No signups"
      @admin_email = User.find_admin.preference.admin_email
      render :action => "nosignup"
    end        
  end

  def create
    user = User.new(params['user'])
    unless user.valid?
      session['new_user'] = user
      redirect_to :controller => 'login', :action => 'signup'
      return
    end

    user.is_admin = true if User.no_users_yet?
    if user.save
      @user = User.authenticate(user.login, params['user']['password'])
      @user.create_preference
      @user.save
      notify :notice, "Signup successful for user #{@user.login}."
      redirect_back_or_default :controller => "todo", :action => "index"
    end
  end

  def delete
    if params['id'] and ( params['id'] == @user.id or @user.is_admin )
      @user = User.find(params['id'])
      # TODO: Maybe it would be better to mark deleted. That way user deletes can be reversed.
      @user.destroy
    end
    redirect_back_or_default :controller => "todo", :action => "index"
  end

  def logout
    session['user_id'] = nil
    reset_session
    notify :notice, "You have been logged out of Tracks."
    redirect_to :action => "login"
  end
  
  def check_expiry
    # Gets called by periodically_call_remote to check whether 
    # the session has timed out yet
    unless session == nil
      if session
        return unless should_expire_sessions?
        # Get expiry time (allow ten seconds window for the case where we have none)
        expiry_time = session['expiry_time'] || Time.now + 10
        @time_left = expiry_time - Time.now
        if @time_left < (10*60) # Session will time out before the next check
          @msg = "Session has timed out. Please "
        else
          @msg = ""
        end
      end
    end
  end
  
  private
  
  def get_new_user
    if session['new_user']
      user = session['new_user']
      session['new_user'] = nil
    else
      user = User.new
    end
    user
  end
    
  def should_expire_sessions?
    session['noexpiry'] != "on"
  end
  
end
