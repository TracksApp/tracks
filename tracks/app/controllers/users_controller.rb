class UsersController < ApplicationController

  if Tracks::Config.openid_enabled?
     open_id_consumer
     before_filter  :begin_open_id_auth,    :only => :update_auth_type
  end

  before_filter :admin_login_required, :only => [ :index, :show, :destroy ]
  skip_before_filter :login_required, :only => [ :new, :create ]
  prepend_before_filter :login_optional, :only => [ :new, :create ]
  
  # GET /users
  # GET /users.xml
  def index
    @users  = User.find(:all, :order => 'login')
    respond_to do |format|
      format.html do
        @page_title = "TRACKS::Manage Users"
        @user_pages, @users = paginate :users, :order => 'login ASC', :per_page => 10
        @total_users = User.count
        # When we call users/signup from the admin page
        # we store the URL so that we get returned here when signup is successful
        store_location
      end
      format.xml { render :xml => @users.to_xml(:except => [ :password ]) }
    end
  end
  
  # GET /users/somelogin
  # GET /users/somelogin.xml
  def show
    @user = User.find_by_login(params[:id])
    render :xml => @user.to_xml(:except => [ :password ])
  end

  # GET /users/new
  def new
    if User.no_users_yet?
      @page_title = "TRACKS::Sign up as the admin user"
      @heading = "Welcome to TRACKS. To get started, please create an admin account:"
      @user = get_new_user
    elsif @user && @user.is_admin?
      @page_title = "TRACKS::Sign up a new user"
      @heading = "Sign up a new user:"
      @user = get_new_user
    else # all other situations (i.e. a non-admin is logged in, or no one is logged in, but we have some users)
      @page_title = "TRACKS::No signups"
      @admin_email = User.find_admin.preference.admin_email
      render :action => "nosignup", :layout => "login"
      return
    end
    render :layout => "login"
  end
  
  # Example usage: curl -H 'Accept: application/xml' -H 'Content-Type: application/xml'
  #               -u admin:up2n0g00d
  #               -d '<request><login>username</login><password>abc123</password></request>'
  #               http://our.tracks.host/users
  #
  # POST /users
  # POST /users.xml
  def create
    if params['exception']
      render_failure "Expected post format is valid xml like so: <request><login>username</login><password>abc123</password></request>."
      return
    end
    respond_to do |format|
      format.html do
        unless User.no_users_yet? || (@user && @user.is_admin?)
          @page_title = "No signups"
          @admin_email = User.find_admin.preference.admin_email
          render :action => "nosignup", :layout => "login"
          return
        end
        
        user = User.new(params['user'])
        unless user.valid?
          session['new_user'] = user
          redirect_to :action => 'new'
          return
        end

        first_user_signing_up = User.no_users_yet?
        user.is_admin = true if first_user_signing_up
        if user.save
          @user = User.authenticate(user.login, params['user']['password'])
          @user.create_preference
          @user.save
          session['user_id'] = @user.id if first_user_signing_up
          notify :notice, "Signup successful for user #{@user.login}."
          redirect_back_or_home
        end
        return
      end
      format.xml do
        unless User.find_by_id_and_is_admin(session['user_id'], true)
          render :text => "401 Unauthorized: Only admin users are allowed access to this function.", :status => 401
          return
        end
        unless check_create_user_params
          render_failure "Expected post format is valid xml like so: <request><login>username</login><password>abc123</password></request>."
          return
        end
        user = User.new(params[:request])
        user.password_confirmation = params[:request][:password]
        if user.save
          render :text => "User created.", :status => 200
        else
          render_failure user.errors.to_xml
        end
        return
      end
    end
  end  
  
  # DELETE /users/somelogin
  # DELETE /users/somelogin.xml
  def destroy
    @deleted_user = User.find_by_id(params[:id])
    @saved = @deleted_user.destroy
    @total_users = User.find(:all).size
    
    respond_to do |format|
      format.html do
        if @saved
          notify :notice, "Successfully deleted user #{@deleted_user.login}", 2.0
        else
          notify :error, "Failed to delete user #{@deleted_user.login}", 2.0
        end
        redirect_to users_url
      end
      format.js
      format.xml { head :ok }
    end
  end
  
    
  def change_password
    @page_title = "TRACKS::Change password"
  end
  
  def update_password
    @user.change_password(params[:updateuser][:password], params[:updateuser][:password_confirmation])
    notify :notice, "Password updated."
    redirect_to :controller => 'preferences'
  rescue Exception => error
    notify :error, error.message
    redirect_to :action => 'change_password'
  end

  def change_auth_type
    @page_title = "TRACKS::Change authentication type"
  end
  
  def update_auth_type
    if (params[:user][:auth_type] == 'open_id') && Tracks::Config.openid_enabled?
      case open_id_response.status
        when OpenID::SUCCESS
          # The URL was a valid identity URL. Now we just need to send a redirect
          # to the server using the redirect_url the library created for us.
          session['openid_url'] = params[:openid_url]

          # redirect to the server
          redirect_to open_id_response.redirect_url((request.protocol + request.host_with_port + "/"), url_for(:action => 'complete'))
        else
          notify :warning, "Unable to find openid server for <q>#{openid_url}</q>"
          redirect_to :action => 'change_auth_type'
      end
      return
    end
    @user.auth_type = params[:user][:auth_type]
    if @user.save
      notify :notice, "Authentication type updated."
      redirect_to :controller => 'preferences'
    else
      notify :warning, "There was a problem updating your authentication type: #{ @user.errors.full_messages.join(', ')}"
      redirect_to :action => 'change_auth_type'
    end
  end
  
  def complete
    return unless Tracks::Config.openid_enabled?
    openid_url = session['openid_url']
    if openid_url.blank?
      notify :error, "expected an openid_url"
    end
    case open_id_response.status
      when OpenID::FAILURE
        # In the case of failure, if info is non-nil, it is the
        # URL that we were verifying. We include it in the error
        # message to help the user figure out what happened.
        if open_id_response.identity_url
          msg = "Verification of #{openid_url}(#{open_id_response.identity_url}) failed. "
        else
          msg = "Verification failed. "
        end
        notify :error, open_id_response.msg.to_s + msg

      when OpenID::SUCCESS
        # Success means that the transaction completed without
        # error. If info is nil, it means that the user cancelled
        # the verification.
        @user.auth_type = 'open_id'
        @user.open_id_url = openid_url
        if @user.save
          notify :notice, "You have successfully verified #{openid_url} as your identity and set your authentication type to Open ID."
        else
          notify :warning, "You have successfully verified #{openid_url} as your identity but there was a problem saving your authentication preferences."
        end
        redirect_to :controller => 'preferences', :action => 'index'

      when OpenID::CANCEL
        notify :warning, "Verification cancelled."

      else
        notify :warning, "Unknown response status: #{open_id_response.status}"
    end
    redirect_to :action => 'change_auth_type' unless performed?
  end
  
  
  def refresh_token
    @user.crypt_word
    @user.save
    notify :notice, "New token successfully generated"
    redirect_to :controller => 'preferences', :action => 'index'
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
    
  def check_create_user_params
    return false unless params.has_key?(:request)
    return false unless params[:request].has_key?(:login)
    return false if params[:request][:login].empty?
    return false unless params[:request].has_key?(:password)
    return false if params[:request][:password].empty?
    return true
  end
  
  
end