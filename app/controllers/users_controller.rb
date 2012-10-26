class UsersController < ApplicationController
  
  before_filter :admin_login_required, :only => [ :index, :show, :destroy ]
  skip_before_filter :login_required, :only => [ :new, :create ]
  skip_before_filter :check_for_deprecated_password_hash,
    :only => [ :change_password, :update_password ]
  prepend_before_filter :login_optional, :only => [ :new, :create ]

  # GET /users GET /users.xml
  def index
    respond_to do |format|
      format.html do
        @page_title = "TRACKS::Manage Users"
        @users = User.paginate :page => params[:page], :order => 'login ASC'
        @total_users = User.count
        # When we call users/signup from the admin page we store the URL so that
        # we get returned here when signup is successful
        store_location
      end
      format.xml do
        @users  = User.order('login').all
        render :xml => @users.to_xml(:except => [ :password ])
      end
    end
  end

  # GET /users/id GET /users/id.xml
  def show
    @user = User.find(params[:id])
    render :xml => @user.to_xml(:except => [ :password ])
  end

  # GET /users/new
  def new
    @auth_types = []
    unless session[:cas_user]
      Tracks::Config.auth_schemes.each {|auth| @auth_types << [auth,auth]}
    else
      @auth_types << ['cas','cas']
    end

    if User.no_users_yet?
      @page_title = t('users.first_user_title')
      @heading = t('users.first_user_heading')
      @user = get_new_user
    elsif (@user && @user.is_admin?) || SITE_CONFIG['open_signups']
      @page_title = t('users.new_user_title')
      @heading = t('users.new_user_heading')
      @user = get_new_user
    else # all other situations (i.e. a non-admin is logged in, or no one is logged in, but we have some users)
      @page_title = t('users.no_signups_title')
      @admin_email = User.find_admin.preference.admin_email
      render :action => "nosignup", :layout => "login"
      return
    end
    render :layout => "login"
  end

  # Example usage: curl -H 'Accept: application/xml' -H 'Content-Type:
  # application/xml'
  #               -u admin:up2n0g00d
  #               -d '<request><login>username</login><password>abc123</password></request>'
  #               http://our.tracks.host/users
  #
  # POST /users POST /users.xml
  def create
    if params['exception']
      render_failure "Expected post format is valid xml like so: <user><login>username</login><password>abc123</password></user>."
      return
    end
    respond_to do |format|
      format.html do
        unless User.no_users_yet? || (@user && @user.is_admin?) || SITE_CONFIG['open_signups']
          @page_title = t('users.no_signups_title')
          @admin_email = User.find_admin.preference.admin_email
          render :action => "nosignup", :layout => "login"
          return
        end

        user = User.new(params['user'])

        if Tracks::Config.auth_schemes.include?('ldap') &&
            user.auth_type == 'ldap' &&
            !SimpleLdapAuthenticator.valid?(user.login, params['user']['password'])
          notify :warning, "Incorrect password"
          redirect_to signup_path
          return
        end

        if Tracks::Config.auth_schemes.include?('cas')
          if user.auth_type.eql? "cas"
             user.crypted_password = "cas"
          end
        end

        unless user.valid?
          session['new_user'] = user
          redirect_to signup_path
          return
        end

        first_user_signing_up = User.no_users_yet?
        user.is_admin = true if first_user_signing_up
        if user.save
          @user = User.authenticate(user.login, params['user']['password'])
          @user.create_preference({:locale => I18n.locale})
          @user.save
          session['user_id'] = @user.id if first_user_signing_up
          notify :notice, t('users.signup_successful', :username => @user.login)
          redirect_back_or_home
        end
        return
      end
      format.xml do
        unless current_user && current_user.is_admin
          render :text => "401 Unauthorized: Only admin users are allowed access to this function.", :status => 401
          return
        end
        unless check_create_user_params
          render_failure "Expected post format is valid xml like so: <user><login>username</login><password>abc123</password></user>.", 400
          return
        end
        user = User.new(params[:user])
        user.password_confirmation = params[:user][:password]
        saved = user.save
        unless user.new_record?
          render :text => t('users.user_created'), :status => 200
        else
          render_failure user.errors.to_xml, 409
        end
        return
      end
    end
  end

  # DELETE /users/id DELETE /users/id.xml
  def destroy
    @deleted_user = User.find(params[:id])
    @saved = @deleted_user.destroy
    @total_users = User.all.size

    respond_to do |format|
      format.html do
        if @saved
          notify :notice, t('users.successfully_deleted_user', :username => @deleted_user.login)
        else
          notify :error, t('users.failed_to_delete_user', :username => @deleted_user.login)
        end
        redirect_to users_url
      end
      format.js
      format.xml { head :ok }
    end
  end

  def change_password
    @page_title = t('users.change_password_title')
  end

  def update_password
    # is used for focing password change after sha->bcrypt upgrade
    current_user.change_password(params[:user][:password], params[:user][:password_confirmation])
    notify :notice, t('users.password_updated')
    redirect_to preferences_path
  rescue Exception => error
    notify :error, error.message
    redirect_to change_password_user_path(current_user)
  end

  def change_auth_type
    @page_title = t('users.change_auth_type_title')
  end

  def update_auth_type
    current_user.auth_type = params[:user][:auth_type]
    if current_user.save
      notify :notice, t('users.auth_type_updated')
      redirect_to preferences_path
    else
      notify :warning, t('users.auth_type_update_error', :error_messages => current_user.errors.full_messages.join(', '))
      redirect_to change_auth_type_user_path(current_user)
    end
  end

  def refresh_token
    current_user.generate_token
    current_user.save!
    notify :notice, t('users.new_token_generated')
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
    return false unless params.has_key?(:user)
    return false unless params[:user].has_key?(:login)
    return false if params[:user][:login].empty?
    return false unless params[:user].has_key?(:password)
    return false if params[:user][:password].empty?
    return true
  end

end
