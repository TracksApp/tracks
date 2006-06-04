require_dependency "user"

module LoginSystem 
  
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

    if session['user_id'] and authorize?(User.find(session['user_id']))
      return true
    end
    
    http_user, http_pass = get_basic_auth_data
    if user = User.authenticate(http_user, http_pass)
      session['user_id'] = user.id
      return true
    end

    # store current location so that we can 
    # come back after the user logged in
    store_location
  
    # call overwriteable reaction to unauthorized access
    access_denied
    return false 
  end

  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    respond_to do |wants|
      wants.html { redirect_to :controller=>"login", :action =>"login" }
      wants.js { render :partial => 'login/redirect_to_login' }
      wants.xml { basic_auth_denied }
    end
  end  
  
  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session['return-to'] = request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session['return-to'].nil?
      redirect_to default
    else
      redirect_to_url session['return-to']
      session['return-to'] = nil
    end
  end
  
  # HTTP Basic auth code adapted from Coda Hale's simple_http_auth plugin. Thanks, Coda!
  def get_basic_auth_data
    
    auth_locations = ['REDIRECT_REDIRECT_X_HTTP_AUTHORIZATION',
                      'REDIRECT_X_HTTP_AUTHORIZATION',
                      'X-HTTP_AUTHORIZATION', 'HTTP_AUTHORIZATION']
    
    authdata = nil
    for location in auth_locations
      if request.env.has_key?(location)
        authdata = request.env[location].to_s.split
      end
    end
    if authdata and authdata[0] == 'Basic' 
      user, pass = Base64.decode64(authdata[1]).split(':')[0..1] 
    else
      user, pass = ['', '']
    end
    return user, pass
  end
  
  def basic_auth_denied
      response.headers["Status"] = "Unauthorized"
      response.headers["WWW-Authenticate"] = "Basic realm=\"'Tracks Login Required'\""
      render :text => "401 Unauthorized: You are not authorized to interact with Tracks.", :status => 401
  end
  

end