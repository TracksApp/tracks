class SeleniumHelperController < ActionController::Base
  def login
    if params[:as]
      session['user_id'] = User.find_by_login(params[:as].to_s)
    end
    render :text => "Logged in as #{params[:as]}"
  end
end

ActionController::Routing::Routes.add_route '/selenium_helper/login', :controller => 'selenium_helper', :action => 'login'

module SeleniumOnRails::TestBuilderActions
  def login options = {}
    options = {options => nil} unless options.is_a? Hash
    opts = {:controller => 'selenium_helper', :action => 'login'}.merge(options)
    open opts
  end
end
