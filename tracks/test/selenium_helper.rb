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

# The accessors available for SeleniumOnRails::TestBuilder tests.
#
# For each +store_foo+ there's +assert_foo+, +assert_not_foo+, +verify_foo+,
# +verify_not_foo+, +wait_for_foo+, +wait_for_not_foo+.
module SeleniumOnRails::TestBuilderAccessors
  # Has an alert occurred? 
  #
  # Related Assertions, automatically generated:
  # * +assert_context_count+
  # * +assert_not_context_count+
  # * +verify_context_count+
  # * +verify_not_context_count+
  # * +wait_for_context_count+
  # * +wait_for_not_context_count+
  def store_context_count variable_name
    command 'storeContextCount', variable_name
  end
  
  each_assertion 'store_context_count' do |assertion_method, command_name|
    define_method assertion_method do |expected_count|
       command command_name, expected_count
    end
  end
  
end