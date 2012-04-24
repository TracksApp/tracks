require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SimpleLdapAuthenticator
  cattr_accessor :fake_success

  def self.valid?(login, pass)
    fake_success
  end
end

class UserTest < ActiveSupport::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :recurring_todos

  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
    assert Tracks::Config.auth_schemes.include?('ldap')
    @admin_user = User.find(1)
    @other_user = User.find(2)
  end

  # Test an admin user model
  #
  def test_admin
    assert_kind_of User, @admin_user
    assert_equal 1, @admin_user.id
    assert_equal "admin", @admin_user.login
    assert_not_nil @admin_user.crypted_password
    assert_not_nil @admin_user.token
    assert @admin_user.is_admin
  end

  # Test a non-admin user model
  def test_non_admin
    assert_kind_of User, @other_user
    assert_equal 2, @other_user.id
    assert_equal "jane", @other_user.login
    assert_not_nil @other_user.crypted_password
    assert_not_nil @other_user.token
    assert @other_user.is_admin == false || @other_user.is_admin == 0
  end

  # ============================================
  # Validations
  # ============================================

  # Test a password shorter than 5 characters
  #
  def test_validate_short_password
    assert_no_difference 'User.count' do
      u = create_user :password => generate_random_string(4)
      assert_equal "is too short (minimum is 5 characters)", u.errors[:password][0]
    end
  end

  def test_validate_long_password
    assert_no_difference 'User.count' do
      u = create_user :password => generate_random_string(41)
      assert_equal "is too long (maximum is 40 characters)", u.errors[:password][0]
    end
  end

  def test_validate_correct_length_password
    assert_difference 'User.count' do
      create_user :password => generate_random_string(6)
    end
  end

  def test_validate_missing_password
    assert_no_difference 'User.count' do
      u = create_user :password => ''
      assert_equal ["can't be blank", "is too short (minimum is 5 characters)"], u.errors[:password]
    end
  end

  def test_validate_short_login
    assert_no_difference 'User.count' do
      u = create_user :login => 'ba'
      assert_equal "is too short (minimum is 3 characters)", u.errors[:login][0]
    end
  end

  def test_validate_long_login
    assert_no_difference 'User.count' do
      u = create_user :login => generate_random_string(81)
      assert_equal "is too long (maximum is 80 characters)", u.errors[:login][0]
    end
  end
  
  def test_validate_correct_length_login
    assert_difference 'User.count' do
      create_user :login => generate_random_string(6)
    end
  end

  def test_validate_missing_login
    assert_no_difference 'User.count' do
      u = create_user :login => ''
      assert_equal ["can't be blank", "is too short (minimum is 3 characters)"], u.errors[:login]
    end
  end

  def test_display_name_with_first_and_last_name_set
    @other_user.first_name = "Jane"
    @other_user.last_name = "Doe"
    assert_equal "Jane Doe", @other_user.display_name
  end

  def test_display_name_with_first_name_set
    @other_user.first_name = "Jane"
    @other_user.last_name = nil
    assert_equal "Jane", @other_user.display_name
  end

  def test_display_name_with_last_name_set
    @other_user.first_name = nil
    @other_user.last_name = "Doe"
    assert_equal "Doe", @other_user.display_name
  end

  def test_display_name_with_neither_first_nor_last_name_set
    @other_user.first_name = nil
    @other_user.last_name = nil
    assert_equal @other_user.login, @other_user.display_name
  end

  def test_prefs_is_short_for_preference
    assert_equal @admin_user.preference, @admin_user.prefs
  end

  def test_to_param_returns_login
    assert_equal @admin_user.login, @admin_user.to_param
  end

  def test_change_password
    assert_not_nil User.authenticate(@admin_user.login, "abracadabra")
    @admin_user.change_password("foobar", "foobar")
    @admin_user.reload
    assert_nil User.authenticate(@admin_user.login, "abracadabra")
    assert_not_nil User.authenticate(@admin_user.login, "foobar")
  end

  def test_projects_next_project
    moremoney = projects(:moremoney)
    next_project = @admin_user.projects.next_from(moremoney)
    assert_equal projects(:gardenclean), next_project
  end

  def test_projects_previous_project
    moremoney = projects(:moremoney)
    previous_project = @admin_user.projects.previous_from(moremoney)
    assert_equal projects(:timemachine), previous_project
  end

  def test_projects_next_project_nil
    gardenclean = projects(:gardenclean)
    next_project = @admin_user.projects.next_from(gardenclean)
    assert_nil next_project
  end

  def test_projects_previous_project_nil
    timemachine = projects(:timemachine)
    previous_project = @admin_user.projects.previous_from(timemachine)
    assert_nil previous_project
  end

  def test_no_users_yet
    assert !User.no_users_yet?
    User.delete_all
    assert User.no_users_yet?
  end

  def test_generate_token_updates_token
    assert_value_changed @admin_user, :token do
      @admin_user.send :generate_token
    end
  end

  def test_find_admin
    assert_equal @admin_user, User.find_admin
  end

  def test_validates_auth_type
    @other_user.auth_type = 'dnacheck'
    assert !@other_user.save
    assert_equal 1, @other_user.errors.count
    assert_equal ["not a valid authentication type (dnacheck)"], @other_user.errors[:auth_type]
  end

  def test_authenticate_can_use_ldap
    u = @other_user
    u.auth_type = 'ldap'
    u.save!
    SimpleLdapAuthenticator.fake_success = false
    assert_nil User.authenticate(u.login, 'foobar')
    SimpleLdapAuthenticator.fake_success = true
    assert_equal @other_user, User.authenticate(u.login, 'foobar')
  end

  def test_find_context_by_params
    u = @admin_user
    c = u.contexts.find_by_params('id' => '1')
    assert_equal contexts(:agenda), c
    c = u.contexts.find_by_params('context_id' => '1')
    assert_equal contexts(:agenda), c
  end

  def test_find_project_by_params
    u = @admin_user
    p = u.projects.find_by_params('id' => '1')
    assert_equal projects(:timemachine), p
    p = u.projects.find_by_params('project_id' => '1')
    assert_equal projects(:timemachine), p
  end

  def test_update_project_positions
    assert_equal 1, Project.find(1).position
    assert_equal 2, Project.find(2).position
    assert_equal 3, Project.find(3).position

    @admin_user.projects.update_positions([2,1,3])

    assert_equal 2, Project.find(1).position
    assert_equal 1, Project.find(2).position
    assert_equal 3, Project.find(3).position
  end

  def test_find_and_activate_deferred_todos_that_are_ready
    assert_equal 1, @admin_user.deferred_todos.count
    @admin_user.deferred_todos[0].show_from = Time.now.utc - 5.seconds
    @admin_user.deferred_todos[0].save
    @admin_user.deferred_todos.reload
    @admin_user.deferred_todos.find_and_activate_ready
    @admin_user.deferred_todos.reload
    assert_equal 0, @admin_user.deferred_todos.count
  end
  
  def test_sort_active_projects_alphabetically
    u = users(:admin_user)
    u.projects.alphabetize(:state => "active")
    assert_equal 1, projects(:timemachine).position
    assert_equal 2, projects(:gardenclean).position
    assert_equal 3, projects(:moremoney).position
  end
  
  def test_sort_active_projects_alphabetically_case_insensitive
    u = users(:admin_user)
    projects(:timemachine).name = projects(:timemachine).name.downcase
    projects(:timemachine).save!
    u.projects.alphabetize(:state => "active")
    assert_equal 1, projects(:timemachine).position
    assert_equal 2, projects(:gardenclean).position
    assert_equal 3, projects(:moremoney).position
  end

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors[:login][0]
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors[:password][0]
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors[:password_confirmation][0]
    end
  end

  def test_should_reset_password
    users(:other_user).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:other_user), User.authenticate('jane', 'new password')
  end
  
  def test_should_not_rehash_password
    users(:other_user).update_attributes(:login => 'jane2')
    assert_equal users(:other_user), User.authenticate('jane2', 'sesame')
  end
  
  def test_should_authenticate_user
    assert_equal users(:other_user), User.authenticate('jane', 'sesame')
  end
  
  def test_should_set_remember_token
    users(:other_user).remember_me
    assert_not_nil users(:other_user).remember_token
    assert_not_nil users(:other_user).remember_token_expires_at
  end
  
  def test_should_unset_remember_token
    users(:other_user).remember_me
    assert_not_nil users(:other_user).remember_token
    users(:other_user).forget_me
    assert_nil users(:other_user).remember_token
  end
  
  def test_should_discover_using_depracted_password
    assert_nil @admin_user.uses_deprecated_password?
    assert_nil @other_user.uses_deprecated_password?
    assert users(:user_with_sha1_password).uses_deprecated_password?
  end

  def test_should_not_have_deprecated_password_after_update
    u = users(:user_with_sha1_password)
    assert u.uses_deprecated_password?
    u.change_password("foobar", "foobar")
    assert_nil u.uses_deprecated_password?
  end

  def test_should_authenticate_with_deprecated_password
    assert_nil User.authenticate('mr_deprecated', 'wrong password')
    assert_equal users(:user_with_sha1_password),
      User.authenticate('mr_deprecated', 'foobar')
  end

  def test_password_matches
    assert_not_nil User.authenticate(@admin_user.login, "abracadabra")
    assert_nil User.authenticate(@admin_user.login, "incorrect")
    assert_not_nil User.authenticate(users(:user_with_sha1_password).login, "foobar")
    assert_nil User.authenticate(users(:user_with_sha1_password).login, "wrong")
  end
  
  
  protected
    def create_user(options = {})
      options[:password_confirmation] = options[:password] unless options.has_key?(:password_confirmation) || !options.has_key?(:password)
      User.create({ :login => 'quire', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
    
    def assert_open_id_url_normalized_on_save(initial, expected)
      u = users(:other_user)
      u.open_id_url = initial
      u.save
      assert_equal expected, u.open_id_url
    end
    
end
