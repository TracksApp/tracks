class AdminController < ApplicationController

  before_filter :admin_login_required
  
  def index
    @user_pages, @users = paginate :users, :order => 'login ASC', :per_page => 10
    @total_users = User.find(:all).size
    # When we call login/signup from the admin page
    # we store the URL so that we get returned here when signup is successful
    store_location
  end

  def destroy
    @deleted_user = User.find_by_id(params[:id])
    @saved = @deleted_user.destroy
    @total_users = User.find(:all).size
    
    respond_to do |wants|
      
      wants.html do
        if @saved
          notify :notice, "Successfully deleted user #{@deleted_user.login}", 2.0
          redirect_to :action => 'index'
        else
          notify :error, "Failed to delete user #{@deleted_user.login}", 2.0
          redirect_to :action => 'index'
        end
      end
      
      wants.js do
        render
      end
      
      wants.xml { render :text => '200 OK. User deleted.', :status => 200 }
    
    end
  end
  
  protected
  
  def admin_login_required
    unless User.find_by_id_and_is_admin(session['user_id'], true)
      notify :error, "Only admin users are allowed access to this function"
      redirect_to home_path
      return false
    end
  end
  
end
