require_dependency "user"

module LoginSystem

  def current_user
    get_current_user
  end

  def prefs
    current_user.prefs unless current_user.nil?
  end

  # Logout the {#current_user} and redirect to login page
  #
  # @param [String] message notification to display
  def logout_user message=t('login.logged_out')
    @user.forget_me if logged_in?
    cookies.delete :auth_token
    session['user_id'] = nil
    if ( SITE_CONFIG['authentication_schemes'].include? 'cas')  && session[:cas_user]
      CASClient::Frameworks::Rails::Filter.logout(self)
    else
      reset_session
      notify :notice, message
      redirect_to_login
    end
  end

  protected

  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights
  # example:
  #
  #  # only allow nonbobs
  #  def authorize?(user)
  #    user.login != "bob"
  #  end
  def authorize?(user)
     true
  end

  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  #
  #  # don't protect the login and the about method
  #  def protect?(action)
  #    if ['action', 'about'].include?(action)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def protect?(action)
    true
  end

  # When called with before_filter :login_from_cookie will check for an :auth_token
  # cookie and log the user back in if appropriate
  def login_from_cookie
    return unless cookies[:auth_token] && !logged_in?
    token = cookies[:auth_token]
    user = User.where(:remember_token => token).first
    if user && user.remember_token?
      session['user_id'] = user.id
      set_current_user(user)
      current_user.remember_me
      cookies[:auth_token] = { :value => current_user.remember_token , :expires => current_user.remember_token_expires_at, :secure => SITE_CONFIG['secure_cookies'] }
      flash[:notice] = t('login.successful')
    end
  end

  def login_or_feed_token_required
    if ['rss', 'atom', 'txt', 'ics'].include?(params[:format])
      if user = User.where(:token => params[:token]).first
        set_current_user(user)
        return true
      end
    end
    login_required
  end

  # login_required filter. add
  #
  #   before_filter :login_required
  #
  # if the controller should be under any rights management.
  # for finer access control you can overwrite
  #
  #   def authorize?(user)
  #
  def login_required

    if not protect?(action_name)
      return true
    end

    login_from_cookie

    if session['user_id'] and authorize?(get_current_user)
      return true
    end

    auth = get_basic_auth_data
    if user = User.authenticate(auth[:user], auth[:pass])
      session['user_id'] = user.id
      set_current_user(user)
      return true
    end

    # store current location so that we can
    # come back after the user logged in
    store_location unless params[:format] == 'js'

    # call overwriteable reaction to unauthorized access
    access_denied
    return false
  end

  def login_optional

    login_from_cookie

    if session['user_id'] and authorize?(get_current_user)
      return true
    end

    auth = get_basic_auth_data
    if user = User.authenticate(auth[:user], auth[:pass])
      session['user_id'] = user.id
      set_current_user(user)
      return true
    end

    return true
  end

  def logged_in?
    current_user != nil
  end

  def get_current_user
    if @user.nil? && session['user_id']
      @user = User.find(session['user_id'])
    end
    @user
  end

  def set_current_user(user)
    @user = user
  end

  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation.
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    respond_to do |format|
      format.html { redirect_to login_path }
      format.m { redirect_to login_path(:format => 'm') }
      format.js { render :partial => 'login/redirect_to_login' }
      format.any(:xml, :rss, :atom, :text) { basic_auth_denied }
    end
  end

  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session['return-to'] = request.url
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session['return-to'].nil?
      redirect_to default
    else
      redirect_to session['return-to']
      session['return-to'] = nil
    end
  end

  # HTTP Basic auth code adapted from Coda Hale's simple_http_auth plugin. Thanks, Coda!
  def get_basic_auth_data

    auth_locations = ['REDIRECT_REDIRECT_X_HTTP_AUTHORIZATION',
                      'REDIRECT_X_HTTP_AUTHORIZATION',
                      'X-HTTP_AUTHORIZATION', 'HTTP_AUTHORIZATION']

    authdata = nil
    auth_locations.each do |location|
      if request.env.has_key?(location)
        authdata = request.env[location].to_s.split
      end
    end
    if authdata and authdata[0] == 'Basic'
      data = Base64.decode64(authdata[1]).split(':')[0..1]
      {
        user: data[0],
        pass: data[1]
      }
    else
      {}
    end
  end

  def basic_auth_denied
      response.headers["WWW-Authenticate"] = "Basic realm=\"'Tracks Login Required'\""
      render :text => t('login.unsuccessful'), :status => 401
  end

private

  # Redirect the user to the login page.
  def redirect_to_login
    respond_to do |format|
      format.html { redirect_to login_path }
      format.m { redirect_to login_path(:format => 'm') }
    end
  end

end
