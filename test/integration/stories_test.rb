require 'test_helper'

class StoriesTest < ActionDispatch::IntegrationTest
  
  # ####################################################
  # Testing login and signup by different kinds of users
  # ####################################################
  def test_signup_new_user_by_admin
    admin = new_session_as(:admin_user,"abracadabra")
    admin.goes_to_signup
    admin.signs_up_with(:user => {:login => "newbie",
                                  :password => "newbiepass",
                                  :password_confirmation => "newbiepass"})
  end
  
  def test_signup_new_user_by_nonadmin
    SITE_CONFIG['open_signups'] = false
    other_user = new_session_as(:other_user,"sesame")
    other_user.goes_to_signup_as_nonadmin
  end
  
  def test_open_signup_new_user
    SITE_CONFIG['open_signups'] = true
    get "/signup"
    assert_response :success
    assert_template "users/new"
    post "/users", :user => {:login => "newbie",
                                  :password => "newbiepass",
                                  :password_confirmation => "newbiepass"}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "todos/index"
  end    
  
  private

    module CustomAssertions

      attr_reader :user

      def logs_in_as(user,plain_pass)
        @user = user
        post "/login", :user_login => @user.login,
                      :user_password => plain_pass,
                      :user_noexpiry => 'n'
        assert_response :redirect
        follow_redirect!
        assert_response :success
        assert_template "todos/index"
      end

      def goes_to_login
        get "/login"
        assert_response :success
        assert_template "login/login"
      end

      def goes_to_signup
        get "/signup"
        assert_response :success
        assert_template "users/new"
      end
      
      def goes_to_signup_as_nonadmin
        get "/signup"
        assert_response :success
        assert_template "users/nosignup"
      end

      def signs_up_with(options)
        post "/users", options
        assert_response :redirect
        follow_redirect!
        assert_response :success
        assert_template "todos/index"
      end
      
    end

    def new_session_as(user,plainpass)
      open_session do |sess|
        sess.extend(CustomAssertions)
        sess.goes_to_login
        sess.logs_in_as(users(user),plainpass)
        yield sess if block_given?
      end
    end
    
end
