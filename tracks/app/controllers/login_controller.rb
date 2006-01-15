class LoginController < ApplicationController
  model   :user
  layout  'login'
  skip_before_filter :set_session_expiration

  def login
    @page_title = "TRACKS::Login"
    case @request.method
      when :post
        if @session['user'] = User.authenticate(@params['user_login'], @params['user_password'])
          # If checkbox on login page checked, we don't expire the session after 1 hour
          # of inactivity
          @session['noexpiry']= @params['user_noexpiry']
          if @session['noexpiry'] == "on"
            msg = "will not expire."
          else
            msg = "will expire after 1 hour of inactivity."
          end
          flash['notice']  = "Login successful: session #{msg}"
          redirect_back_or_default :controller => "todo", :action => "list"
        else
          @login    = @params['user_login']
          @message  = "Login unsuccessful"
      end
    end
  end

  def signup
    unless (User.find_all.empty? || ( @session['user'] && @session['user']['is_admin'] ) )
      @page_title = "No signups"
      render :action => "nosignup"
      return
    end
    @signupname = User.find_all.empty? ? "as the admin":"a new"
    @page_title = "Sign up #{@signupname} user"

    if @session['new_user']
      @user = @session['new_user']
      @session['new_user'] = nil
    else
      @user = User.new
    end
  end

  def create
    user = User.new(@params['user'])
    unless user.valid?
      @session['new_user'] = user
      redirect_to :controller => 'login', :action => 'signup'
      return
    end

    user.is_admin = 1 if User.find_all.empty?
    if user.save
      @session['user'] = User.authenticate(user.login, @params['user']['password'])
      flash['notice']  = "Signup successful"
      redirect_back_or_default :controller => "todo", :action => "list"
    end
  end

  def delete
    if @params['id'] and ( @params['id'] = @session['user'].id or @session['user'].is_admin )
      @user = User.find(@params['id'])
      # TODO: Maybe it would be better to mark deleted. That way user deletes can be reversed.
      @user.destroy
    end
    redirect_back_or_default :controller => "todo", :action => "list"
  end

  def logout
    @session['user'] = nil
    reset_session
    flash['notice']  = "You have been logged out of Tracks."
    redirect_to :controller => "login", :action => "login"
  end

  def welcome
  end
  
  def check_expiry
    # Gets called by periodically_call_remote to check whether 
    # the session has timed out yet
    unless @session == nil
      return if @controller_name == 'feed' or @session['noexpiry'] == "on"
      # If the method is called by the feed controller 
      # (which we don't have under session control)
      # or if we checked the box to keep logged in on login
      # then the session is not going to get called
      if @session
        # Get expiry time (allow ten seconds window for the case where we have none)
        expiry_time = @session['expiry_time'] || Time.now + 10
        @time_left = expiry_time - Time.now
        if @time_left < (10*60) # Session will time out before the next check
          @msg = "Session has timed out. Please "
        else
          @msg = ""
        end
      end
    end
  end

end
