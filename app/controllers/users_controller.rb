class UsersController < ApplicationController
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
        @users = User.paginate :page => params[:page], :order => 'login ASC'
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
    elsif (@user && @user.is_admin?) || SITE_CONFIG['open_signups']
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
        unless User.no_users_yet? || (@user && @user.is_admin?) || SITE_CONFIG['open_signups']
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
    @deleted_user = User.find_by_login(params[:id])
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
    redirect_to preferences_path
  rescue Exception => error
    notify :error, error.message
    redirect_to :action => 'change_password'
  end

  def change_auth_type
    @page_title = "TRACKS::Change authentication type"
  end
  
  def update_auth_type
    if (params[:open_id_complete] || (params[:user][:auth_type] == 'open_id')) && openid_enabled?
      authenticate_with_open_id do |result, identity_url|
        if result.successful?
          # Success means that the transaction completed without
          # error. If info is nil, it means that the user cancelled
          # the verification.
          @user.auth_type = 'open_id'
          @user.open_id_url = identity_url
          if @user.save
            notify :notice, "You have successfully verified #{identity_url} as your identity and set your authentication type to Open ID."
          else
            debugger
            notify :warning, "You have successfully verified #{identity_url} as your identity but there was a problem saving your authentication preferences."
          end
          redirect_to preferences_path
        else
          notify :warning, result.message
          redirect_to :action => 'change_auth_type'
        end
      end
      return
    end
    @user.auth_type = params[:user][:auth_type]
    if @user.save
      notify :notice, "Authentication type updated."
      redirect_to preferences_path
    else
      notify :warning, "There was a problem updating your authentication type: #{ @user.errors.full_messages.join(', ')}"
      redirect_to :action => 'change_auth_type'
    end
  end
  
  def refresh_token
    @user.generate_token
    @user.save!
    notify :notice, "New token successfully generated"
    redirect_to preferences_path
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
