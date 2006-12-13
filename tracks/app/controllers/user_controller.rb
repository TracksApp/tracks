class UserController < ApplicationController

  if Tracks::Config.auth_schemes.include?('open_id')
     open_id_consumer
     before_filter  :begin_open_id_auth,    :only => :update_auth_type
  end
  
  verify  :method => :post,
          :only => %w( create ),
          :render => { :text => '403 Forbidden: Only POST requests on this resource are allowed.',
                      :status => 403 }
  
  # Example usage: curl -H 'Accept: application/xml' -H 'Content-Type: application/xml'
  #               -u admin:up2n0g00d
  #               -d '<request><login>username</login><password>abc123</password></request>'
  #               http://our.tracks.host/user/create
  #
  def create
     if params['exception']
       render_failure "Expected post format is valid xml like so: <request><login>username</login><password>abc123</password></request>."
       return
     end

     admin = User.find_admin
      unless session["user_id"].to_i == admin.id.to_i
        access_denied
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
  end
    
  def preferences
    @page_title = "TRACKS::Preferences"
    @prefs = @user.preference
  end

  def edit_preferences
    @page_title = "TRACKS::Edit Preferences"
    @prefs = @user.preference
    
    render :action => "preference_edit_form", :object => @prefs
  end
  
  def update_preferences
    user_success = @user.update_attributes(params['user'])
    prefs_success = @user.preference.update_attributes(params['prefs'])
    if user_success && prefs_success
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
      redirect_to :controller => 'preferences'
    else
      redirect_to :controller => 'user', :action => 'change_password'
      notify :warning, "There was a problem saving the password. Please retry."
    end
  end

  def change_auth_type
    @page_title = "TRACKS::Change authentication type"
  end
  
  def update_auth_type
    if (params[:user][:auth_type] == 'open_id')
      case open_id_response.status
        when OpenID::SUCCESS
          # The URL was a valid identity URL. Now we just need to send a redirect
          # to the server using the redirect_url the library created for us.

          # redirect to the server
          redirect_to open_id_response.redirect_url((request.protocol + request.host_with_port + "/"), url_for(:action => 'complete'))
        else
          notify :warning, "Unable to find openid server for <q>#{params[:openid_url]}</q>"
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
      redirect_to :controller => 'user', :action => 'change_auth_type'
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
        @user.auth_type = 'open_id'
        @user.open_id_url = open_id_response.identity_url
        if @user.save
          notify :notice, "You have successfully verified #{open_id_response.identity_url} as your identity and set your authentication type to Open ID."
        else
          notify :warning, "You have successfully verified #{open_id_response.identity_url} as your identity but there was a problem saving your authentication preferences."
        end
        redirect_to :action => 'preferences'

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
    redirect_to :controller => 'user', :action => 'preferences'
  end
  
  protected
  
  def do_change_password_for(user)
    user.change_password(params[:updateuser][:password], params[:updateuser][:password_confirmation])
    if user.save
      notify :notice, "Password updated."
      return true
    else
      notify :error, 'There was a problem saving the password. Please retry.'
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