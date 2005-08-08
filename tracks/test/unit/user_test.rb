require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @admin_user = User.find(1)
    @other_user = User.find(2)
  end

  # Test an admin user model
  def test_admin
    assert_kind_of User, @admin_user
    assert_equal 1, @admin_user.id
    assert_equal "admin", @admin_user.login
    assert_equal "#{Digest::SHA1.hexdigest("change-me--abracadabra--")}", @admin_user.password
    assert_equal "#{Digest::SHA1.hexdigest("change-me--badger--")}", @admin_user.word
    assert_equal 1, @admin_user.is_admin
  end

  # Test a non-admin user model
  def test_non_admin
    assert_kind_of User, @other_user
    assert_equal 2, @other_user.id
    assert_equal "jane", @other_user.login
    assert_equal "#{Digest::SHA1.hexdigest("change-me--sesame--")}", @other_user.password
    assert_equal "#{Digest::SHA1.hexdigest("change-me--mouse--")}", @other_user.word
    assert_equal 0, @other_user.is_admin
  end

  def test_validate_short_password
    assert_equal "#{Digest::SHA1.hexdigest("change-me--sesame--")}", @other_user.password
    @other_user.password = "four"
    assert !@other_user.save
    assert_equal 1, @other_user.errors.count
    assert_equal "is too short (min is 5 characters)", @other_user.errors.on(:password)
  end

  # Test a password longer than 40 characters
  def test_validate_long_password
    assert_equal "#{Digest::SHA1.hexdigest("change-me--sesame--")}", @other_user.password
    @other_user.password = generate_random_string(41)
    assert !@other_user.save
    assert_equal 1, @other_user.errors.count
    assert_equal "is too long (max is 40 characters)", @other_user.errors.on(:password)
  end
  
  def test_validate_correct_length_password
    assert_equal "#{Digest::SHA1.hexdigest("change-me--sesame--")}", @other_user.password
    @other_user.password = generate_random_string(6)
    assert @other_user.save
  end
  
  # Test an invalid user with no password
  def test_validate_missing_password
    assert_equal 2, @other_user.id
    @other_user.password = ""
    assert !@other_user.save
    assert_equal 2, @other_user.errors.count
    assert_equal ["can't be blank", "is too short (min is 5 characters)"], @other_user.errors.on(:password)
  end
end
