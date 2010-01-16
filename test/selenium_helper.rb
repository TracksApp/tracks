class SeleniumHelperController < ActionController::Base
  def login
    if params[:as]
      user = User.find_by_login(params[:as].to_s)
      session['user_id'] = user
      user.contexts.each do |c|
        cookies["tracks_#{user.login}_context_c#{c.id}_collapsed"] = nil
      end
    end
    
    render :text => "Logged in as #{params[:as]}"
  end
end

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
  
  # How many elements with the class "context" are present on the page? 
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

  def drag_todo_to(id1, id2)
    mouse_down_at "css=#line_todo_#{id1} img.grip", "4,4"
    mouse_move_at "line_todo_#{id2}", '20,3'
    mouse_over "line_todo_#{id2}"
    mouse_up_at "line_todo_#{id2}", '20,3'
  end
  
  def assert_context_count_incremented(&block)
    store_context_count 'initial_context_count'
    store_eval "${initial_context_count} + 1", 'expected_context_count'
    yield
    wait_for_context_count "${expected_context_count}"
  end

  def click_and_wait clickable
    click clickable
    wait_for_page_to_load 3000
  end

end
